extends Control
var channel
var nicks = {}
@onready var scroll_container = $ScrollContainer
@onready var scroll = $ScrollContainer/VBoxContainer

var is_scrolled_up = false

const IRC_SPECIAL_NICK_PREFIES = ["@", "+", "%", "&", "~"]
const COLORS = [
	"#ff0000",
	"#00ff00",
	"#0000ff",
	"#ffff00",
	"#00ffff",
	"#ff00ff",
	"#ff8000",
	"#ff0080",
	"#8000ff",
	"#0080ff",
	"#ff8000",
	"#ff0080",
]


func _ready():
	scroll_container.get_v_scroll_bar().connect("value_changed", Callable(self, "on_scroll"))


func add_nicks(nicknames):
	for nickname in nicknames:
		for prefix in IRC_SPECIAL_NICK_PREFIES:
			if nickname.begins_with(prefix):
				nickname = nickname.substr(1, nickname.length())
				break
		nicks[nickname] = COLORS[hash(nickname) % len(COLORS)]


func add_message(text, nick = null, color = null):
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.size_flags_vertical = SIZE_EXPAND_FILL
	label.custom_minimum_size.x = get_parent().get_size().x
	label.selection_enabled = true

	var _text = ""
	var prefix = ""

	if nick != null:  # choose color from hash
		var _color = COLORS[hash(nick) % len(COLORS)]
		prefix += "[color=%s][b]%s[/b][/color]: " % [_color, nick]
	if color != null:
		_text += "[color=" + color + "]" + text + "[/color]"
	else:
		_text += StringUtils.irc_to_bbcode(text)

	if color == null:
		for _nick in nicks:
			var regex = RegEx.new()
			regex.compile("\\b" + _nick + "\\b")
			_text = regex.sub(_text, "[color=" + nicks[_nick] + "]" + _nick + "[/color]", true)

	_text = prefix + _text
	label.text = _text
	print("----------------------------------------")
	print(_text)
	scroll.add_child(label)


func _max_scrollbar_value():
	return scroll_container.get_v_scroll_bar().max_value


func scroll_to_bottom():
	if is_scrolled_up:
		return
	scroll_container.scroll_vertical = _max_scrollbar_value()


func clear():
	for child in scroll.get_children():
		child.queue_free()


# TODO when user has scrolled up, dont scrolldown with someone's else message
func on_scroll(_value):  # is_scrolled_up = true
	if scroll_container.scroll_vertical == _max_scrollbar_value():
		is_scrolled_up = false
		print("Scrolling ended")
