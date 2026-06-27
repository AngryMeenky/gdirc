extends Object
class_name StringUtils


enum {
	LITERAL,
	BOLD,
	COLOR,
	HEX_COLOR,
	RESET,
	MONOSPACE,
	REVERSE,
	ITALIC,
	STRIKETHROUGH,
	UNDERLINE,
}

static var _COLORS: PackedStringArray = [
	"ffffff", "000000", "00007f", "009300", "ff0000",
	"7f0000", "9c009c", "fc7f00", "ffff00", "00fc00",
	"009393", "00ffff", "0000fc", "ff00ff", "7f7f7f",
	"d2d2d2", "470000", "472100", "474700", "324700",
	"004700", "00472c", "004747", "002747", "000047",
	"2e0047", "470047", "47002a", "740000", "743a00",
	"747400", "517400", "007400", "007449", "007474",
	"004074", "000074", "4b0074", "740074", "740045",
	"b50000", "b56300", "b5b500", "7db500", "00b500",
	"00b571", "00b5b5", "0063b5", "0000b5", "7500b5",
	"b500b5", "b5006b", "ff0000", "ff8c00", "ffff00",
	"b2ff00", "00ff00", "00ffa0", "00ffff", "008cff",
	"0000ff", "a500ff", "ff00ff", "ff0098", "ff5959",
	"ffb459", "ffff71", "cfff60", "6fff6f", "65ffc9",
	"6dffff", "59b4ff", "5959ff", "c459ff", "ff66ff",
	"ff59bc", "ff9c9c", "ffd39c", "ffff9c", "e2ff9c",
	"9cff9c", "9cffdb", "9cffff", "9cd3ff", "9c9cff",
	"dc9cff", "ff9cff", "ff94d3", "000000", "131313",
	"282828", "363636", "4d4d4d", "656565", "818181",
	"9f9f9f", "bcbcbc", "e2e2e2", "ffffff", "000000"
]
static var _ESCAPES: PackedStringArray = [
	"\u0002", # bold
	"\u0003", # color
	"\u0004", # hex ccolor
	"\u000F", # reset
	"\u0011", # monospace
	"\u0016", # reverse color
	"\u001D", # italics
	"\u001E", # strikethrough
	"\u001F", # underline
]
static var _CLR_REG := RegEx.create_from_string("\u0003(\\d{1,2}|\\d{1,2},\\d{1,2})")
static var _HEX_REG := RegEx.create_from_string("\u0003([[:xdigit:]]{6}|[[:xdigit:]]{6},[[:xdigit:]]{6})")


# Join an array from strings starting from the given start_index
static func join_from(args: Array, start_index = 0) -> String:
	var string = ""
	var i = -1

	for word in args:
		i += 1
		if i < start_index:
			continue
		string += word + " "
	return string


static func irc_to_format_list(line: String) -> Array[Array]:
	var escapes := _find_all(line, _ESCAPES) # find all the escapes
	var result: Array[Array] = []

	if escapes.is_empty():
		result.append([ LITERAL, line ])
		return result

	var idx     := 0
	var clr     := 0
	var hex     := 0
	var bold    := false
	var reset   := false
	var mono    := false
	var reverse := false
	var italic  := false
	var strike  := false
	var under   := false
	for escape: int in escapes:
		if escape > idx:
			result.append([ LITERAL, line.substr(idx, escape - idx)])

		match line[escape]:
			"\u0002": # bold
				bold = not bold
				idx = escape + 1
				result.append([ BOLD, bold ])
			"\u0003": # color
				var cm := _CLR_REG.search(line, escape, escape + 6)
				if cm != null:
					clr += 1
					var val := cm.get_string(0)
					idx = escape + val.length() + 1
					var colors := val.split(",")
					var code := colors[0].to_int()
					if colors.size() == 2:
						var bgcode := colors[1].to_int()
						result.append([ COLOR, _COLORS[code], _COLORS[bgcode] ])
					else:
						result.append([ COLOR, _COLORS[code] ])
				else:
					clr -= 1
					idx = escape + 1
					result.append([ COLOR ])
			"\u0004": # hex ccolor
				var cm := _HEX_REG.search(line, escape, escape + 6)
				if cm != null:
					hex += 1
					var val := cm.get_string(0)
					idx = escape + val.length() + 1
					var colors := val.split(",")
					if colors.size() == 2:
						result.append([ HEX_COLOR, colors[0], colors[1] ])
					else:
						result.append([ HEX_COLOR, colors[0] ])
				else:
					hex -= 1
					idx = escape + 1
					result.append([ COLOR ])
			"\u000F": # reset
				idx = escape + 1
				clr     = 0
				hex     = 0
				bold    = false
				reset   = false
				mono    = false
				reverse = false
				italic  = false
				strike  = false
				under   = false
				result.append([ RESET ])
			"\u0011": # monospace
				mono = not mono
				idx = escape + 1
				result.append([ MONOSPACE, mono ])
			"\u0016": # reverse color
				reverse = not reverse
				idx = escape + 1
				result.append([ REVERSE, reverse ])
			"\u001D": # italics
				italic = not italic
				idx = escape + 1
				result.append([ ITALIC, italic ])
			"\u001E": # strikethrough
				strike = not strike
				idx = escape + 1
				result.append([ STRIKETHROUGH, strike ])
			"\u001F": # underline
				under = not under
				idx = escape + 1
				result.append([ UNDERLINE, under ])
	if clr > 0 or hex > 0 or bold or reset or mono or reverse or italic or strike or under:
		result.append([ RESET ])

	return result


static func _untangle(result: PackedStringArray, stack: Array[Array], cmd: int) -> void:
	var min = -stack.size()
	var idx = -1

	# close all the tags in reverse order
	while idx > min:
		match stack[idx][0]:
			BOLD:
				result.append("[/b]")
			COLOR, HEX_COLOR:
				result.append("[/color][/bgcolor]" if stack[idx].size() > 2 else "[/color]")
			RESET:
				pass
			MONOSPACE:
				result.append("[/code]")
			REVERSE:
				pass
			ITALIC:
				result.append("[/i]")
			STRIKETHROUGH:
				result.append("[/s]")
			UNDERLINE:
				result.append("[/u]")

		if stack[idx][0] == cmd:
			stack.remove_at(idx)
			idx += 1
			break

	# reopen all the tags in the correct order
	while idx < 0:
		match stack[idx][0]:
			BOLD:
				result.append("[b]")
			COLOR, HEX_COLOR:
				var val := stack[idx]
				if val.size() > 2:
					result.append("[bgcolor=#%s][color=#%s]" % [ val[2], val[1] ])
				else:
					result.append("[color=#%s]" % val[1])
			RESET:
				pass
			MONOSPACE:
				result.append("[code]")
			REVERSE:
				pass
			ITALIC:
				result.append("[i]")
			STRIKETHROUGH:
				result.append("[s]")
			UNDERLINE:
				result.append("[u]")
		idx += 1


static func _simple_tag(result: PackedStringArray, stack: Array[Array], cmd: Array, open: String, close: String) -> void:
	if cmd[1]:
		stack.append(cmd)
		result.append(open)
	elif stack.back()[1] == cmd[0]:
		result.append(close)
		stack.pop_back()
	else:
		_untangle(result, stack, cmd[0])


static func formatting_to_bbcode(formatting: Array[Array]) -> String:
	var stack: Array[Array] = []
	var result: PackedStringArray = []

	for cmd in formatting:
		match cmd[0]:
			LITERAL:
				result.append(cmd[1].replace("[", "[lb]"))
			BOLD:
				_simple_tag(result, stack, cmd, "[b]", "[/b]")
			COLOR:
				if cmd.size() > 1:
					stack.append(cmd)
					if cmd.size() > 2:
						result.append("[bgcolor=#%s][color=#%s]" % [ cmd[2], cmd[1] ])
					else:
						result.append("[color=#%s]" % cmd[1])
				else:
					_untangle(result, stack, COLOR)
			HEX_COLOR:
				if cmd.size() > 1:
					stack.append(cmd)
					if cmd.size() > 2:
						result.append("[bgcolor=#%s][color=#%s]" % [ cmd[2], cmd[1] ])
					else:
						result.append("[color=#%s]" % cmd[1])
				else:
					_untangle(result, stack, HEX_COLOR)
			RESET:
				pass
			MONOSPACE:
				_simple_tag(result, stack, cmd, "[code]", "[/code]")
			REVERSE:
				pass
			ITALIC:
				_simple_tag(result, stack, cmd, "[i]", "[/i]")
			STRIKETHROUGH:
				_simple_tag(result, stack, cmd, "[s]", "[/s]")
			UNDERLINE:
				_simple_tag(result, stack, cmd, "[u]", "[/u]")

	return "".join(result)


static func _find_all(haystack: String, needles: PackedStringArray) -> PackedInt64Array:
	var result: PackedInt64Array = []

	for needle: String in needles:
		var idx := haystack.find(needle)
		while idx >= 0:
			result.append(idx)
			idx = haystack.find(needle, idx + 1)

	result.sort()
	return result


static func _untangle_rtl(rtl: RichTextLabel, stack: Array[Array], cmd: int) -> void:
	var min = -stack.size()
	var idx = -1

	# close all the tags in reverse order
	while idx > min:
		rtl.pop()

		if stack[idx][0] == cmd:
			stack.remove_at(idx)
			idx += 1
			break

	# reopen all the tags in the correct order
	while idx < 0:
		match stack[idx][0]:
			BOLD:
				rtl.push_bold()
			COLOR, HEX_COLOR:
				var val := stack[idx]
				if val.size() > 2:
					rtl.push_bgcolor(Color.hex(val[2]))
					rtl.push_color(Color.hex(val[1]))
				else:
					rtl.push_color(Color.hex(val[1]))
			RESET:
				pass
			MONOSPACE:
				rtl.push_mono()
			REVERSE:
				pass
			ITALIC:
				rtl.push_italics()
			STRIKETHROUGH:
				rtl.push_strikethrough()
			UNDERLINE:
				rtl.push_underline()
		idx += 1


static func formatting_to_rich_text(rtl: RichTextLabel, list: Array[Array]) -> void:
	var stack: Array[Array] = []

	for cmd in list:
		match cmd[0]:
			LITERAL:
				rtl.add_text(cmd[1])
			BOLD:
				if cmd[1]:
					rtl.push_bold()
				elif stack.back()[1] == cmd[0]:
					stack.pop_back()
					rtl.pop()
				else:
					_untangle_rtl(rtl, stack, cmd[0])
			COLOR, HEX_COLOR:
				if cmd.size() > 1:
					stack.append(cmd)
					if cmd.size() > 2:
						rtl.push_bgcolor(Color.hex(cmd[2]))
						rtl.push_color(Color.hex(cmd[1]))
					else:
						rtl.push_color(Color.hex(cmd[1]))
				else:
					_untangle_rtl(rtl, stack, cmd[0])
			RESET:
				rtl.pop_all()
				stack.clear()
			MONOSPACE:
				if cmd[1]:
					rtl.push_mono()
				elif stack.back()[1] == cmd[0]:
					stack.pop_back()
					rtl.pop()
				else:
					_untangle_rtl(rtl, stack, cmd[0])
			REVERSE:
				pass
			ITALIC:
				if cmd[1]:
					rtl.push_italics()
				elif stack.back()[1] == cmd[0]:
					stack.pop_back()
					rtl.pop()
				else:
					_untangle_rtl(rtl, stack, cmd[0])
			STRIKETHROUGH:
				if cmd[1]:
					rtl.push_strikethrough()
				elif stack.back()[1] == cmd[0]:
					stack.pop_back()
					rtl.pop()
				else:
					_untangle_rtl(rtl, stack, cmd[0])
			UNDERLINE:
				if cmd[1]:
					rtl.push_underline()
				elif stack.back()[1] == cmd[0]:
					stack.pop_back()
					rtl.pop()
				else:
					_untangle_rtl(rtl, stack, cmd[0])


static func irc_to_rich_text(line: String, rtl: RichTextLabel) -> void:
	formatting_to_rich_text(rtl, irc_to_format_list(line))


static func irc_to_bbcode(line: String) -> String:
	return formatting_to_bbcode(irc_to_format_list(line))
