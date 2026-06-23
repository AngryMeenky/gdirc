extends Control


# The URL we will connect to
@export var server = "irc.example.local"
@export var url = "ircs://irc.example.local:6697"
@export var channel = "#godot"
@export var debug: bool = false
@export var nick = "godot"

@onready var tab_container := $TabContainer
@onready var text_edit := $TextEdit
@onready var client: IRC = $IRC
var buffers: Dictionary
var currentchannel: String

enum Commands {
	KICK,
	MODE,
	HELP,
	CLEAR,
	ME,
	PART,
	NICK,
	JOIN,
	TOPIC,
	MSG,
	QUIT,
	OP,
	NAMES,
	QUOTE,
	LIST,
}

const command_prefix = "/"

const CMD_HELP = {
	Commands.KICK: "Usage: /kick <user> [reason]",
	Commands.HELP: "Usage: /help <command>",
	Commands.CLEAR: "Clears the screen",
	Commands.ME: "Sends a message as an action. Usage: /me <message>",
	Commands.PART: "Usage: /part <channel>",
	Commands.NICK: "Usage: /nick <new nickname.",
	Commands.JOIN: "Usage: /join <channel>",
	Commands.TOPIC: "Usage: /topic <topic>",
	Commands.MSG: "Usage: /msg <nick> <message>",
	Commands.QUIT: "Usage: /quit <message>",
	Commands.OP: "Usage: /op <nick>",
	Commands.NAMES: "Usage: /names [channel]",
	Commands.QUOTE: "Usage: /quote <raw_irc_command>",
	Commands.LIST: "List channels in the server. Usage: /list [opt]",
}


func _ready():
	client.nick = nick
	client.user = nick
	client.network = server
	client.debug = debug
	client.connect_to_server(url)

	text_edit.grab_focus()
	create_buffer(server)


func _error(err: String):
	print(err)


func _closed():
	add_text("Connection closed.")


func _connected():
	print("GUI: comms channel connected")
	buffers[server].add_message("CONNECTED...", null, "red")


func _on_established():
	if not channel.is_empty():
		client.join_channel(channel)


func _on_event(ev: IrcEvent):
	match ev.ordinal:
		IRC.Commands.MODE:
			add_text(
				ev.get_source() + " has set mode " + ev.mode + " on channel " + ev.get_target() + "",
				ev.get_target()
			)
		IRC.Commands.KICK:
			add_text(
				ev.get_arg(0) + " was kicked by " + ev.get_source() + ": " + ev.get_text() + "",
				ev.get_target()
			)
			print(ev.channel)
		IRC.Commands.QUIT:
			add_text(ev.get_source() + " has quit.", ev.get_target())
		IRC.Commands.PRIVMSG:
			if ev.ctcp.is_empty():
				buffers[ev.get_target()].add_message(ev.get_text(), ev.get_source())
			else:
				for ctcp: PackedStringArray in ev.ctcp:
					if ctcp[0] == "ACTION":
						add_text(ev.get_target() + " -> " + ev.get_source() + ": " + "*" + ctcp[1] + "*", ev.get_target())
					pass
		IRC.Commands.PART:
			add_text(ev.get_source() + " has parted " + ev.get_target() + ".", ev.get_target())
		IRC.Commands.JOIN:
			if ev.get_source() == nick:
				create_buffer(ev.get_arg(ev.get_arg_count() - 1))
			else:
				add_text(ev.get_source() + " has joined.", ev.get_target())
		IRC.Commands.NAMES:
			add_text("Users in channel: " + str(ev.list) + "", ev.channel)
			if ev.channel in buffers:
				buffers[ev.get_target()].add_nicks(ev.list)
		IRC.Commands.NICK:
			if ev.get_source() == client.nick:
				add_text("You are now known as " + ev.get_arg(0) + "", ev.get_target())
				nick = ev.get_source()
			else:
				add_text(ev.get_source() + " is now known as " + ev.nick + "", ev.get_target())
		IRC.Commands.ERR_NICKNAMEINUSE: # NICK_IN_USE
			add_text("That nickname is already in use!", ev.get_target())
		IRC.Commands.TOPIC:
			var pre = ""
			if ev.nick:
				pre = "Topic set by " + ev.nick
			else:
				pre = "TOPIC"
			add_text(pre + ': "' + ev.get_text() + '"', ev.get_target())
		IRC.Commands.ERR_CHANOPRIVSNEEDED: # ERR_CHANOPRIVSNEEDED
			add_text(" -> Error: " + ev.message + "", ev.channel)
		IRC.Commands.LIST:
			for chan in ev.list:
				add_text(str(chan) + "")
			add_text("")
		_:
			if ev.ordinal >= IRC.Commands.RPL_WELCOME:
				add_text(ev.get_text())

	buffers[currentchannel].scroll_to_bottom()


func _input(ev):
	if ev.is_action_pressed("send"):
		_on_Send_pressed()


func help(cmd, suffix = ""):
	cmd = cmd.to_upper()
	if not cmd in Commands.keys():
		add_text(suffix + "No help for: /" + cmd + "")
		return
	var help_msg = CMD_HELP[Commands.keys().find(cmd)]
	add_text(suffix + "/" + cmd + ": " + help_msg + "")
	return


# Given a prefix will find if there is any or multiple corresponding commands with that prefix
func find_commands_from_prefix(prefix: String) -> PackedStringArray:
	prefix = prefix.to_upper()
	var can_be = PackedStringArray()
	for cmd in Commands.keys():
		if not cmd.to_upper().begins_with(prefix):
			continue
		can_be.append(cmd)
	return can_be


func _command(text):
	var whitespace_split = text.split(" ")
	var command = whitespace_split[0].trim_prefix(command_prefix)
	var args = PackedStringArray()

	if len(whitespace_split) > 1:
		args = whitespace_split.slice(1)

	var arglen = len(args)
	command = command.to_upper()

	# Accept shortened prefixes for each command
	var can_be = find_commands_from_prefix(command)
	var cmd_id = -1
	if len(can_be) == 1:
		cmd_id = Commands.keys().find(can_be[0])
	elif len(can_be) > 1:
		add_text(" -> /" + command + " could be multiple commands: " + str(can_be) + "")
		return

	match cmd_id:
		Commands.HELP:
			if arglen > 0:
				help(args[0])

			for cmd in Commands.keys():
				add_text(command_prefix + cmd + "")
			add_text("")
		Commands.KICK:
			client.kick_user(currentchannel, args[0], args[1] if arglen > 1 else "")
		Commands.MODE:
			client.change_mode(currentchannel, args[1], nick)
		Commands.CLEAR:
			buffers[currentchannel].clear()
		Commands.QUOTE:
			client.send_raw(StringUtils.join_from(args))
		Commands.ME:
			client.me(currentchannel, StringUtils.join_from(args))
		Commands.PART:
			client.part_channel(currentchannel)
			delete_buffer(currentchannel)
		Commands.TOPIC:
			match arglen:
				0:
					client.clear_topic(currentchannel)
				_:
					client.change_topic(currentchannel, StringUtils.join_from(args))
		Commands.NICK:
			client.set_nick(args[0])
		Commands.JOIN:
			client.join_channel(args[0])
		Commands.MSG:
			if arglen >= 2:
				client.send_message(args[0], StringUtils.join_from(args, 1))
			else:
				help(command, "Invalid number of arguments    -   ")
		Commands.QUIT:
			client.quit_server(StringUtils.join_from(args))
		Commands.OP:
			match arglen:
				1:
					client.change_mode(currentchannel, "+o", args[0])
				_:
					help(command, "Invalid number of arguments    -   ")
		Commands.LIST:
			client.list_channels(StringUtils.join_from(args))

		_:
			add_text("Unrecognized command: /" + command + "")


func _on_Send_pressed():
	var text: String = text_edit.text
	if text.is_empty():
		return

	# If is command
	if text.begins_with(command_prefix):
		_command(text)
		return

	# Send message to current channel
	client.send_message(currentchannel, text)
	buffers[currentchannel].add_message(text, nick)

	text_edit.text = ""
	buffers[currentchannel].scroll_to_bottom()


func getnick(source):
	return source.split("!")[0]


func add_text(text, channelname = null):
	if channelname && channelname[0] == "#":
		buffers[channelname].add_message(text)
	else:
		buffers[server].add_message(text)


func create_buffer(_channel):
	var buffer = preload("res://Buffer.tscn").instantiate()
	buffer.channel = _channel
	buffers[_channel] = buffer
	buffer.set_name(_channel)
	tab_container.add_child(buffer)
	tab_container.set_current_tab(len(tab_container.get_children()) - 1)


func delete_buffer(_channel):
	tab_container.remove_child(buffers[_channel])
	tab_container.set_current_tab(len(tab_container.get_children()) - 1)
	var current_buffer = tab_container.get_current_tab_control()
	if current_buffer:
		currentchannel = current_buffer.channel
	else:
		currentchannel = server
		tab_container.set_current_tab(0)


func _on_TabContainer_tab_changed(tab):
	currentchannel = tab_container.get_tab_control(tab).channel

# Ctrl + W Closes the current tab
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.ctrl_pressed and event.keycode == KEY_W:
			delete_buffer(currentchannel)
