# REFERENCE: https://modern.ircdocs.horse/

extends Node
class_name IrcClient


enum Proto {
	WS,
	WSS,
	TCP,
	TCPS,
}

# Events
enum {
	MODE,
	KICK,
	QUIT,
	PRIVMSG,
	ACTION,
	JOIN,
	NAMES,
	PART,
	NICK,
	NICK_IN_USE,
	TOPIC,
	LIST,
	ERR_CHANPRIVSNEEDED,
}

const ctcp_escape = "\u0001"

var host: String
var ws_host: String
var nick: String
var username: String
var autojoin_room: String
var port: int
var proto: int
var connected: bool = false
var debug: bool = false

# Either WSBackend ot TCPBackend
var backend

signal comm_connected()
signal error(message: String)
signal event(_event: Event)
signal closed()

var init = false


class Event:
	var source = ""
	var list = PackedStringArray()
	var message = ""
	var nick = ""
	var topic = ""
	var channel = ""
	var mode = ""
	var type: int

	func _init(attrs: Dictionary):
		if not "type" in attrs:
			push_error("Event requires type.")
		if not "source" in attrs:
			push_error("Event requires source.")
		for key in attrs:
			set(key, attrs[key])

	static func make_privmsg(src: String, chan: String, from: String, msg: String) -> Event:
		return Event.new({ "source": src, "type": PRIVMSG, "channel": chan, "nick": from, "message": msg})

	static func make_ctcp(src: String, cmd: int, chan: String, from: String, data: String) -> Event:
		return Event.new({ "source": src, "type": cmd, "channel": chan, "nick": from, "message": data})

	static func make_mode(src: String, chan: String, _mode: String) -> Event:
		return Event.new({ "source": src, "type": MODE, "channel": chan, "mode": _mode})

	static func make_kick(src: String, chan: String, who: String, msg: String) -> Event:
		return Event.new({ "source": src, "type": KICK, "channel": chan, "nick": who, "message": msg})

	static func make_quit(src: String, chan: String) -> Event:
		return Event.new({ "source": src, "type": QUIT, "channel": chan})

	static func make_join(src: String, chan: String) -> Event:
		return Event.new({ "source": src, "type": JOIN, "channel": chan})

	static func make_nick(src: String, _nick: String) -> Event:
		return Event.new({ "source": src, "type": NICK, "nick": _nick})

	static func make_part(src: String, chan: String) -> Event:
		return Event.new({ "source": src, "type": PART, "channel": chan})

	static func make_topic(src: String, chan: String, who: String, msg: String) -> Event:
		return Event.new({ "source": src, "type": TOPIC, "channel": chan, "nick": who, "message": msg})

	static func make_list(src: String, chan: String, _list: PackedStringArray) -> Event:
		return Event.new({ "source": src, "type": LIST, "channel": chan, "list": _list})


class Accumulator:
	var memory: Dictionary

	func _init():
		memory = {}

	func start(key: int):
		memory[key] = []

	func has(key: int):
		return key in memory

	func add(key: int, value):
		memory[key].append(value)

	func pop(key: int):
		var copy = memory[key]
		var _n = memory.erase(key)
		return copy


var accumulator = Accumulator.new()


func get_type(var_name: String) -> int:
	var constant_map: Dictionary = get_script().get_script_constant_map()
	if var_name in constant_map:
		return constant_map[var_name]
	return -1


################################################################################
# Creates a new irc client object.
#
# _nick: Client irc nickname
# _username: Client irc username
#
# _host: Can be a websocket address or irc address. The protoccol must be specified example with default ports:
# irc://irc.example.com:6667
# ircs://irc.example.com:6697
# ws://irc.example.com:7666
# wss://irc.example.com:7669
#
# Those default ports will be used when ommited.
#
# _ws_host: Optional. Fallback websocket host to use. Useful for html5 compatible exports.
#
# _autojoin_room: Optional. Automatically join this room on connect.
func _init(
	_nick: String,
	_username: String,
	_host: String,
	_ws_host: String = "",
	_autojoin_room: String = ""
):
	nick = _nick
	username = _username
	host = _host
	ws_host = _ws_host
	autojoin_room = _autojoin_room

	# WS fallback for html
	if OS.get_name() == "HTML5" and len(ws_host) > 0:
		print("Falling back to websocket backend")
		host = ws_host

	# Parse uri, load defaults
	var split_uri = host.split(":")
	match len(split_uri):
		1:
			host = host
			proto = Proto.TCP
			port = 6667
		2:
			host = split_uri[0]
			port = int(split_uri[1])
			proto = Proto.TCP
		3:
			host = split_uri[1].trim_prefix("//").trim_prefix("/")
			port = int(split_uri[2])

			var scheme = split_uri[0]
			match scheme:
				"irc":
					proto = Proto.TCP
				"ircs":
					proto = Proto.TCPS
				"ws":
					proto = Proto.WS
				"wss":
					proto = Proto.WSS
				_:
					push_error("Unrecognized uri")

		_:
			push_error("Unrecognized uri")

	match OS.get_name():
		"HTML5":
			if not proto in [Proto.WS, Proto.WSS]:
				push_error(
					"TCP is not supported in html5 exports. Use websockets or ws_host as a fallback!"
				)

	# Create backend
	match proto:
		Proto.TCP:
			backend = TcpBackend.new()
			backend.connect_to_host(host, port)

		Proto.TCPS:
			backend = TcpsBackend.new()
			backend.connect_to_host(host, port)

		Proto.WS:
			backend = WsBackend.new()
			backend.host_uri = "ws://" + host + ":" + str(port)

		Proto.WSS:
			backend = WsBackend.new()
			backend.host_uri = "wss://" + host + ":" + str(port)

	# Bind and Connect
	backend.closed.connect(_closed)
	backend.data_received.connect(_data)
	backend.error.connect(_error)
	backend.comm_connected.connect(_connected)
	add_child(backend)


func _closed():
	closed.emit()


func _error(err):
	error.emit(err)


func _connected():
	if connected:
		return
	quote("nick " + nick)
	quote("user " + username + " * * :" + username)
	comm_connected.emit()
	connected = true


func _data(data):
	_connected()

	var acc_key = -10

	# Handle unterminated messages
	if accumulator.has(acc_key):
		data = StringUtils.join_from(accumulator.pop(acc_key)) + data

	var msglist = Array(data.split("\r\n"))
	var last_index = len(msglist) - 1
	if not data.ends_with("\r\n"):
		accumulator.start(acc_key)
		accumulator.add(acc_key, msglist[-1])
		last_index -= 1

	# Process loop
	for msg in msglist.slice(0, last_index):
		if len(msg) == 0:
			continue

		if debug:
			print("<<< ", msg)

		if msg.split(" ")[0] == "PING":
			quote(msg.replace("PI", "PO"))
			continue

		emit_events(msg)


############################
# Parse and process irc protocool
func emit_events(msg):
	if len(msg) < 0:
		return

	msg = msg.strip_edges()
	var args = msg.split(" ")

	# If message is not a reply ignore for now
	if not args[0].begins_with(":") or len(msg.split(" ")) < 2:
		return

	var reply_code = msg.split(" ")[1]

	if not init && reply_code == "376":
		init = true
		if len(autojoin_room) > 0:
			quote("join " + autojoin_room)

	if init:
		var evtype = get_type(args[1].to_upper())
		var source = args[0].trim_prefix(":")
		var from_nick = source.split("!")[0]
		var long_param = ""
		var has_long_param = false
		for arg in Array(args).slice(1):
			if not has_long_param and arg.begins_with(":"):
				has_long_param = true
				long_param += arg.trim_prefix(":")
			elif has_long_param:
				long_param += " " + arg

		var ctcp_command: String = ""
		var ctcp_args: Array = []
		var has_ctcp = false
		var ctcp_type: int
		if has_long_param and long_param.begins_with(ctcp_escape):
			for c in long_param.trim_prefix(ctcp_escape):
				if c == ctcp_escape:
					break
				ctcp_command += c
			ctcp_args = Array(ctcp_command.split(" "))
			ctcp_type = get_type(ctcp_args[0])
			has_ctcp = true

		match evtype:
			PRIVMSG:
				var channel = args[2]
				if has_ctcp:
					match ctcp_type:
						ACTION:
							event.emit(Event.make_ctcp(
								source, ctcp_type, channel, from_nick, ctcp_command.trim_prefix(ctcp_args[0] + " ")
							))
				else:
					event.emit(Event.make_privmsg(source, channel, from_nick, long_param))
			MODE:
				event.emit(Event.make_mode(source, args[2], args[3]))
			KICK:
				event.emit(Event.make_kick(source, args[2], args[3], long_param))
			QUIT:
				event.emit(Event.make_quit(source, long_param))
			JOIN:
				event.emit(Event.make_join(source, long_param))
			NICK:
				event.emit(Event.make_nick(source, long_param))
			PART:
				event.emit(Event.make_part(source, long_param))
			TOPIC:
				event.emit(Event.make_topic(source, args[2], args[3], long_param))

			_:
				match reply_code:
					"433":
						event.emit(Event.new({"source": source, "type": NICK_IN_USE}))

					"353":
						var channel = msg.split(":")[1].split(" ")[4]
						var _names = long_param.split(" ")
						event.emit(Event.make_list(source, channel, _names))

					"332":
						event.emit(Event.make_topic(source, args[3], "", long_param))

					# Unpriviledged ERR
					"482":
						event.emit(Event.new({"source": source, "type": ERR_CHANPRIVSNEEDED, "message": long_param }))

					# LIST
					"321":
						accumulator.start(LIST)
					"322":
						if not accumulator.has(LIST):
							return
						accumulator.add(LIST, StringUtils.join_from(args, 3))

					"323":
						event.emit(Event.make_list(source, "", accumulator.pop(LIST)))

	# Nick in use at login
	elif reply_code == "433":
		nick = nick + "_"
		set_nick(nick)


# Send raw message to irc backend server
func quote(message: String):
	message = message.replace("\n", "")
	if debug:
		print(">>> ", message)
	backend.send(message)


# Sends a private message or a message to a channel
func send(nick_or_channel: String, message: String):
	quote("PRIVMSG %s :%s" % [nick_or_channel, message])


# Changes the nick of the client
# Capture the result with the "NICK" event
func set_nick(new_nick: String):
	quote("nick %s" % [new_nick])


# Joins a channel
# Capture the result with the "JOIN" event
func join(channel: String):
	quote("JOIN %s" % [channel])


# Leaves a channel
# Capture the result with the "PART" event
func part(channel: String):
	quote("PART %s" % [channel])


# Quits the irc server
func quit(message: String):
	quote("QUIT %s" % [message])


# Changes the mode for a specific channel
# TODO Capture the result with the "MODE" event
func mode(channel: String, _mode: String, _nick: String):
	quote("MODE %s %s %s" % [channel, _mode, _nick])


# Kicks a user from a channel with a message
# TODO Capture the result with the "KICK" event
func kick(channel: String, _nick: String, message = ""):
	quote("KICK %s %s : %s" % [channel, _nick, message])


# Changes the topic of a channel
# Capture the result with the "JOIN" event
func topic(channel: String, _topic: String):
	quote("TOPIC %s :%s" % [channel, _topic])


# Gets a list of names from the current channel
# Capture the result with the "NAMES" event
func names(channel: String):
	quote("NAMES %s" % [channel])


# Gets a list of channels in the server.
# Can take a param like ">3" (more than 3 users) or "T<60" (topic change in less than 60 min ago)
# Capture the result with the "LIST" event
func list(param: String = ""):
	quote("LIST " + param)


# Send a custom ctcp command private message
func ctcp(nick_or_channel: String, command: String):
	quote(("PRIVMSG %s :" + ctcp_escape + "%s" + ctcp_escape) % [nick_or_channel, command])


# /me action
func me(nick_or_channel: String, message: String):
	ctcp(nick_or_channel, "ACTION " + message)


# Adds op rights to a nick. Shorthand to /mode channel +o nick
# TODO Capture the result with the "MODE" event
func op(channel: String, _nick: String):
	mode(channel, "+o", _nick)
