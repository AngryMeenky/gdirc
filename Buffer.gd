extends VBoxContainer
class_name IrcBuffer


signal message(target: String, text: String)


@export var nick: String
@export var channel: String
@export var members: = {}
@export var color_nicks := false
@export var is_server := false:
	set(val):
		$Output.collapsed = val
		is_server = val
@export var debug := false

@onready var _members: ItemList = $Output/ScrollContainer/Members
@onready var _output: RichTextLabel = $Output/Text
@onready var _input: LineEdit = $Input/Line


const IRC_SPECIAL_NICK_PREFIES = ["@", "+", "%", "&", "~"]
const COLORS = [
	"#ff0000", "#00ff00", "#0000ff",
	"#ffff00", "#00ffff", "#ff00ff",
	"#ff8000", "#ff0080", "#8000ff",
	"#0080ff", "#ff8000", "#ff0080",
]


func add_nicks(nicknames: PackedStringArray) -> void:
	var count := members.size()
	for who in nicknames:
		members[who] = [ COLORS[hash(who) % len(COLORS)], RegEx.create_from_string("\\b" + who + "\\b") ]
	if members.size() != count:
		_update_member_list()


func add_message(text: String, who = null, color = null) -> void:
	var _text = ""
	var prefix = ""

	if who != null:  # choose color from hash
		var _color = members[who][0] if members.has(who) else COLORS[hash(who) % len(COLORS)]
		prefix = "[color=%s][b]%s[/b][/color]: " % [_color, who]
	if color != null:
		_text = "[color=" + color + "]" + text + "[/color]"
	else:
		_text += StringUtils.irc_to_bbcode(text)

	if color_nicks:
		for _nick in members.keys():
			var regex: RegEx = members[_nick][1]
			_text = regex.sub(_text, "[color=" + members[_nick] + "]" + _nick + "[/color]", true)

	if debug:
		print(channel + " -> " + prefix + _text)

	_output.append_text(prefix + _text + "\r\n")


func clear() -> void:
	_output.clear()


func _update_member_list() -> void:
	_members.clear()
	var keys := members.keys()
	keys.sort()
	for who in keys:
		var idx = _members.add_item(who)
		_members.set_item_custom_fg_color(idx, members[who][0])


func _on_text_submitted(text: String) -> void:
	if not text.is_empty():
		_input.clear()
		add_message(text, nick)
		message.emit(channel, text)


func _on_send_pressed() -> void:
	_on_text_submitted(_input.text)
