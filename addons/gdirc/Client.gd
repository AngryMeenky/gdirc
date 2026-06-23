extends RefCounted
class_name IrcClient
signal conn_established()


static var REGEX := RegEx.create_from_string(
	"(?m)^(?<tags>@[^ ]+)? *(?<source>:[^ ]+)? *(?<command>[^ ]+) *(?<args>.*)?$"
)
static var PARSERS := {
	"ADMIN": _parse_simple_cmd,
	"AUTHENTICATE": _parse_no_args_cmd, 
	"AWAY": _parse_text_cmd,
	"CAP": _parse_cap,
	"CONNECT": _parse_simple_cmd,
	"ERROR": _parse_text_cmd,
	"HELP": _parse_text_cmd,
	"INFO": _parse_no_args_cmd,
	"INVITE": _parse_simple_cmd,
	"JOIN": _parse_simple_cmd,
	"KICK": _parse_text_cmd,
	"KILL": _parse_text_cmd,
	"LINKS": _parse_no_args_cmd,
	"LIST": _parse_simple_cmd,
	"LUSERS": _parse_no_args_cmd,
	"MODE": _parse_simple_cmd,
	"MOTD": _parse_simple_cmd,
	"NAMES": _parse_simple_cmd,
	"NICK": _parse_simple_cmd,
	"NOTICE": _parse_text_cmd,
	"OPER": _parse_simple_cmd,
	"PART": _parse_text_cmd,
	"PASS": _parse_simple_cmd,
	"PING": _parse_simple_cmd,
	"PONG": _parse_simple_cmd,
	"PRIVMSG": _parse_text_cmd,
	"QUIT": _parse_text_cmd,
	"REHASH": _parse_no_args_cmd,
	"RESTART": _parse_no_args_cmd,
	"SQUIT": _parse_text_cmd,
	"STATS": _parse_simple_cmd,
	"TIME": _parse_simple_cmd,
	"TOPIC": _parse_text_cmd,
	"USER": _parse_simple_cmd,
	"USERHOST": _parse_simple_cmd,
	"VERSION": _parse_simple_cmd,
	"WALLOPS": _parse_text_cmd,
	"WHO": _parse_simple_cmd,
	"WHOIS": _parse_simple_cmd,
	"WHOWAS": _parse_simple_cmd,
}

enum Status {
	UNREGISTERED,
	CAP_INIT,
	IDENT_SENT,
	REGISTERED,
	REJECTED
}

enum {
	AVAILABLE,
	REQUESTED,
	ENABLED,
	DISABLED,
}

var _nick: String
var _user: String
var _password: String
var _network: String
var _queue: PackedStringArray = []
var _caps := {}
var _state := Status.UNREGISTERED
var _debug := false
var _wrapper


func _init(nick: String, user: String, password: String, network: String):
	_nick = nick
	_user = user
	_password = password
	_network = network
	reset()


func reset() -> void:
	_state = Status.UNREGISTERED
	_queue.clear()
	_queue.append("CAP LS 302\r\n")
	if not _password.is_empty():
		_queue.append("PASS %s\r\n" % _password)
	_queue.append("NICK %s" % _nick)
	_queue.append("USER %s * * %s" % [ _user, _user ])


func is_setup_complete() -> bool:
	return _state == Status.REGISTERED


func get_response_count() -> int:
	return _queue.size()


func get_response() -> String:
	if _queue.is_empty():
		return ""
	var packet := _queue[0]
	_queue.remove_at(0)
	return packet


func queue_message(msg: String) -> void:
	_queue.append(msg.strip_edges())


func process(raw: String) -> IrcEvent:
	# bail on empty string
	if raw.is_empty():
		return null

	var res := REGEX.search(raw)
	if res == null or res.get_group_count() == 0:
		return null

	var event: IrcEvent = PARSERS.get(res.get_string("command").to_upper(), _parse_text_cmd).call(res, _debug)
	if not event.valid:
		push_warning("Failed to parse: ", raw)
		return null

	if _state != Status.REGISTERED:
		_negotiate(event)
	elif not event.ctcp.is_empty():
		if "PRIVMSG" == event.command:
			_handle_ctcp_request(event)
		elif "NOTICE" == event.command:
			_handle_ctcp_response(event)
		else:
			push_error("Unexpected CTCP in ", event.command)
	elif "PING" == event.command and not event.args.is_empty():
		_queue.append("PONG %s\r\n" % event.args[0])
	return event


func _negotiate(event: IrcEvent) -> void:
	match _state:
		Status.UNREGISTERED:
			if event.ordinal == IRC.Commands.CAP:
				var idx := event.args.size()
				while idx > 0:
					idx -= 1
					_caps[event.args[idx]] = AVAILABLE

				if event.sub_cmds[event.sub_cmds.size() - 1] == "LS":
					# TODO: finish negotiation
					_state = Status.IDENT_SENT
					_queue.append("CAP END\r\n")
		Status.CAP_INIT:
			if event.ordinal == IRC.Commands.ERR_NICKNAMEINUSE:
				_nick += "_"
				_queue.append("NICK %s" % _nick)
			# TODO wait for all ACKs/NAKs
			_state = Status.IDENT_SENT
		Status.IDENT_SENT, Status.REJECTED:
			# wait for MOTD/NICKTAKEN
			if event.ordinal == IRC.Commands.RPL_ENDOFMOTD or event.ordinal == IRC.Commands.RPL_WELCOME:
				_state = Status.REGISTERED
				conn_established.emit()
				print("Negotiating complete")
			elif event.ordinal == IRC.Commands.ERR_NICKNAMEINUSE:
				_nick += "_"
				_queue.append("NICK %s" % _nick)


func _handle_ctcp_request(event: IrcEvent) -> void:
	var response := "NOTICE %s :\u0001" % [ _nick, event.source["nick"] ]
	for ctcp: PackedStringArray in event.ctcp:
		match ctcp[0]:
			"CLIENTINFO":
				response += "CLIENTINFO ACTION DCC CLIENTINFO FINGER PING SOURCE TIME USERINFO VERSION\u0001"
			"FINGER":
				response += "FINGER gdIRC 0.1\u0001"
			"PING":
				response += "%s\u0001" % " ".join(ctcp)
			"SOURCE":
				response += "SOURCE https://github.com/AngryMeenky/gdirc\u0001"
			"TIME":
				response += "TIME %s\u0001" % Time.get_datetime_string_from_system()
			"VERSION":
				response += "FINGER gdIRC 0.1\u0001"
			"USERINFO":
				response += "USERINFO %s (redacted)\u0001" % _nick
	if not response.ends_with(":\u0001"):
		_queue.append(response)


func _handle_ctcp_response(event: IrcEvent) -> void:
	# TODO: handle the responses
	pass


static func _dump_parts(parts: RegExMatch) -> void:
	print("Event: ", parts.subject)
	for key in parts.names.keys():
		print("  ", key, ": ", parts.get_string(key))


static func _parse_no_args_cmd(parts: RegExMatch, debug: bool) -> IrcEvent:
	if debug:
		_dump_parts(parts)
	var tags := parts.get_string("tags")
	var src  := parts.get_string("source")
	var cmd  := parts.get_string("command")
	var args: PackedStringArray = []

	return IrcEvent.new(tags, src, cmd, args)


static func _parse_one_arg_cmd(parts: RegExMatch, debug: bool) -> IrcEvent:
	if debug:
		_dump_parts(parts)
	var tags := parts.get_string("tags")
	var src  := parts.get_string("source")
	var cmd  := parts.get_string("command")
	var args: PackedStringArray = [ parts.get_string("args") ]

	if args[0].is_empty():
		args.clear()

	return IrcEvent.new(tags, src, cmd, args)


static func _parse_cap(parts: RegExMatch, debug: bool) -> IrcEvent:
	if debug:
		_dump_parts(parts)
	var tags := parts.get_string("tags")
	var src  := parts.get_string("source")
	var cmd  := parts.get_string("command")
	var args := parts.get_string("args").split(" ", false)
	var subs: PackedStringArray

	var idx := 0
	while idx < args.size():
		if args[idx].begins_with(":"):
			break
		idx += 1
	if idx < args.size():
		if idx > 0:
			subs = args.slice(0, idx)
			args = args.slice(idx)
		args[0] = args[0].substr(1)
		args.insert(0, ":")
	else:
		subs = []

	return IrcEvent.new(tags, src, cmd, args, subs)


static func _parse_text_cmd(parts: RegExMatch, debug: bool) -> IrcEvent:
	if debug:
		_dump_parts(parts)
	var tags := parts.get_string("tags")
	var src  := parts.get_string("source")
	var cmd  := parts.get_string("command")
	var raw  := parts.get_string("args")
	var args: PackedStringArray

	var idx := raw.find(":")
	if idx > 0:
		args = raw.substr(0, idx).split(" ", false)
		args.append(":")
		args.append(raw.substr(idx + 1))
	elif idx == 0:
		args.append(":")
		args.append(raw.substr(1))

	return IrcEvent.new(tags, src, cmd, args)


static func _parse_simple_cmd(parts: RegExMatch, debug: bool) -> IrcEvent:
	if debug:
		_dump_parts(parts)
	var tags := parts.get_string("tags")
	var src  := parts.get_string("source")
	var cmd  := parts.get_string("command")
	var args := parts.get_string("args").split(" ", false)

	var idx := 0
	while idx < args.size():
		if args[idx].begins_with(":"):
			args[idx] = args[idx].substr(1)
			args.insert(idx, ":")
		idx += 1

	return IrcEvent.new(tags, src, cmd, args)

