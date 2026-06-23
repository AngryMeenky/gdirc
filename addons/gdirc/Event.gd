extends RefCounted
class_name IrcEvent


const _CTCP_ESC := "\u0001"


static var SRC_REGEX := RegEx.create_from_string("(?<nick>[^!]+)(?<user>![^@]+)?(?<host>@.+)?")
static var TAG_REGEX := RegEx.create_from_string("(?<key>[^=]+)(?<value>=[^\\r\\n; ])?")
static var _EMPTY: PackedStringArray = []
static var _MAPPING := {
	"CAP":      IRC.Commands.CAP,      "AUTHENTICATE": IRC.Commands.AUTHENTICATE,
	"PASS":     IRC.Commands.PASS,     "NICK":         IRC.Commands.NICK,
	"USER":     IRC.Commands.USER,     "PING":         IRC.Commands.PING,
	"PONG":     IRC.Commands.PONG,     "OPER":         IRC.Commands.OPER,
	"QUIT":     IRC.Commands.QUIT,     "ERROR":        IRC.Commands.ERROR,
	"JOIN":     IRC.Commands.JOIN,     "PART":         IRC.Commands.PART,
	"TOPIC":    IRC.Commands.TOPIC,    "NAMES":        IRC.Commands.NAMES,
	"LIST":     IRC.Commands.LIST,     "INVITE":       IRC.Commands.INVITE,
	"KICK":     IRC.Commands.KICK,     "MOTD":         IRC.Commands.MOTD,
	"VERSION":  IRC.Commands.VERSION,  "ADMIN":        IRC.Commands.ADMIN,
	"CONNECT":  IRC.Commands.CONNECT,  "LUSERS":       IRC.Commands.LUSERS,
	"TIME":     IRC.Commands.TIME,     "STATS":        IRC.Commands.STATS,
	"HELP":     IRC.Commands.HELP,     "INFO":         IRC.Commands.INFO,
	"MODE":     IRC.Commands.MODE,     "PRIVMSG":      IRC.Commands.PRIVMSG,
	"NOTICE":   IRC.Commands.NOTICE,   "WHO":          IRC.Commands.WHO,
	"WHOIS":    IRC.Commands.WHOIS,    "WHOWAS":       IRC.Commands.WHOWAS,
	"KILL":     IRC.Commands.KILL,     "REHASH":       IRC.Commands.REHASH,
	"RESTART":  IRC.Commands.RESTART,  "SQUIT":        IRC.Commands.SQUIT,
	"AWAY":     IRC.Commands.AWAY,     "LINKS":        IRC.Commands.LINKS,
	"USERHOST": IRC.Commands.USERHOST, "WALLOPS":      IRC.Commands.WALLOPS,
}
static var _FINALIZERS := {
	IRC.Commands.CAP:          _cap_finalizer,
	IRC.Commands.AUTHENTICATE: _bare_finalizer,
	IRC.Commands.PASS:         _text_only_finalizer,
	IRC.Commands.NICK:         _text_only_finalizer,
	IRC.Commands.PING:         _text_only_finalizer,
	IRC.Commands.PONG:         _text_last_finalizer,
	IRC.Commands.OPER:         _simple_finalizer,
	IRC.Commands.QUIT:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERROR:        _optional_text_finalizer,
	IRC.Commands.JOIN:         _simple_finalizer,
	IRC.Commands.PART:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.TOPIC:        _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.NAMES:        _simple_finalizer,
	IRC.Commands.LIST:         _simple_finalizer,
	IRC.Commands.INVITE:       _simple_finalizer,
	IRC.Commands.KICK:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.MOTD:         _targeted_simple_finalizer,
	IRC.Commands.VERSION:      _targeted_simple_finalizer,
	IRC.Commands.ADMIN:        _targeted_simple_finalizer,
	IRC.Commands.CONNECT:      _simple_finalizer,
	IRC.Commands.LUSERS:       _bare_finalizer,
	IRC.Commands.TIME:         _targeted_simple_finalizer,
	IRC.Commands.STATS:        _simple_finalizer,
	IRC.Commands.HELP:         _simple_with_optional_text_finalizer,
	IRC.Commands.INFO:         _bare_finalizer,
	IRC.Commands.MODE:         _targeted_simple_finalizer,
	IRC.Commands.PRIVMSG:      _privmsg_finalizer,
	IRC.Commands.NOTICE:       _privmsg_finalizer,
	IRC.Commands.WHO:          _simple_finalizer,
	IRC.Commands.WHOIS:        _simple_finalizer,
	IRC.Commands.WHOWAS:       _simple_finalizer,
	IRC.Commands.KILL:         _text_last_finalizer,
	IRC.Commands.REHASH:       _bare_finalizer,
	IRC.Commands.RESTART:      _bare_finalizer,
	IRC.Commands.SQUIT:        _text_last_finalizer,
	IRC.Commands.AWAY:         _optional_text_finalizer,
	IRC.Commands.LINKS:        _bare_finalizer,
	IRC.Commands.USERHOST:     _simple_finalizer,
	IRC.Commands.WALLOPS:      _text_only_finalizer,

	IRC.Commands.RPL_WELCOME:  _targeted_text_only_finalizer,
	IRC.Commands.RPL_YOURHOST: _targeted_text_only_finalizer,
	IRC.Commands.RPL_CREATED:  _targeted_text_only_finalizer,
	IRC.Commands.RPL_MYINFO:   _targeted_simple_finalizer,
	IRC.Commands.RPL_ISUPPORT: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_BOUNCE:   _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.RPL_STATSCOMMANDS: _targeted_simple_finalizer,
	IRC.Commands.RPL_ENDOFSTATS:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_UMODEIS:       _targeted_simple_finalizer,
	IRC.Commands.RPL_STATSUPTIME:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_STATSCONN:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERCLIENT:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSEROP:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERUNKNOWN:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERCHANNELS: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERME:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINME:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINLOC1:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINLOC2:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINEMAIL:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TRYAGAIN:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LOCALUSERS:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_GLOBALUSERS:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISCERTFP:   _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.RPL_AWAY:            _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_USERHOST:        _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_UNAWAY:          _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_NOWAWAY:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISREGNICK:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISUSER:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISSERVER:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISOPERATOR:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOWASUSER:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFWHO:        _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISIDLE:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFWHOIS:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISCHANNELS:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISSPECIAL:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LISTSTART:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LIST:            _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LISTEND:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_CHANNELMODEIS:   _targeted_simple_finalizer,
	IRC.Commands.RPL_CREATIONTIME:    _targeted_simple_finalizer,
	IRC.Commands.RPL_WHOISACCOUNT:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_NOTOPIC:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TOPIC:           _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TOPICWHOTIME:    _targeted_simple_finalizer,
	IRC.Commands.RPL_INVITELIST:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFINVITELIST: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISACTUALLY:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_INVITING:        _targeted_simple_finalizer,
	IRC.Commands.RPL_INVEXLIST:       _targeted_simple_finalizer,
	IRC.Commands.RPL_ENDOFINVEXLIST:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_EXCEPTLIST:      _targeted_simple_finalizer,
	IRC.Commands.RPL_ENDOFEXCEPTLIST: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_VERSION:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOREPLY:        _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_NAMREPLY:        _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LINKS:           _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFLINKS:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFNAMES:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_BANLIST:         _targeted_simple_finalizer,
	IRC.Commands.RPL_ENDOFBANLIST:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFWHOWAS:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_INFO:            _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_MOTD:            _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFINFO:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_MOTDSTART:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFMOTD:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISHOST:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISMODES:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_YOUREOPER:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_REHASHING:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TIME:            _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.ERR_UNKNOWNERROR:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOSUCHNICK:        _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOSUCHSERVER:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOSUCHCHANNEL:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CANNOTSENDTOCHAN:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_TOOMANYCHANNELS:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_WASNOSUCHNICK:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOORIGIN:          _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NORECIPIENT:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOTEXTTOSEND:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INPUTTOOLONG:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_UNKNOWNCOMMAND:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOMOTD:            _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NONICKNAMEGIVEN:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_ERRONEUSNICKNAME:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NICKNAMEINUSE:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NICKCOLLISION:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_USERNOTINCHANNEL:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOTONCHANNEL:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_USERONCHANNEL:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOTREGISTERED:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NEEDMOREPARAMS:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_ALREADYREGISTERED: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_PASSWDMISMATCH:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_YOUREBANNEDCREEP:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CHANNELISFULL:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_UNKNOWNMODE:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INVITEONLYCHAN:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_BANNEDFROMCHAN:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_BADCHANNELKEY:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_BADCHANMASK:       _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOPRIVILEGES:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CHANOPRIVSNEEDED:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CANTKILLSERVER:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOOPERHOST:        _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.ERR_UMODEUNKNOWNFLAG: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_USERSDONTMATCH:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_HELPNOTFOUND:     _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INVALIDKEY:       _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.RPL_STARTTLS:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISSECURE:      _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_STARTTLS:         _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INVALIDMODEPARAM: _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.RPL_HELPSTART: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_HELPTXT:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFHELP: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOPRIVS:   _targeted_simple_with_optional_text_finalizer,

	IRC.Commands.RPL_LOGGEDIN:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LOGGEDOUT:   _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NICKLOCKED:  _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_SASLSUCCESS: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLFAIL:    _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLTOOLONG: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLABORTED: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLALREADY: _targeted_simple_with_optional_text_finalizer,
	IRC.Commands.RPL_SASLMECHS:   _targeted_simple_with_optional_text_finalizer,
}

var ordinal := 0 
var parsed := {}
var args: PackedStringArray
var command := ""
var sub_cmds: PackedStringArray
var ctcp: Array[PackedStringArray] = []
var valid: bool


func _init(tag_str: String, src: String, cmd: String, arg_list: PackedStringArray, subs: PackedStringArray = []):
	if not tag_str.is_empty():
		parsed[&"tags"] = _parse_tags(tag_str)
	if not src.is_empty():
		parsed[&"source"] = _parse_source(src)
	args = arg_list
	command = cmd.to_upper()
	sub_cmds = subs

	# handle CTCP
	if args.size() == 2 and args[1].begins_with(_CTCP_ESC) and (cmd == "NOTICE" or cmd == "PRIVMSG"):
		for part: String in args[1].split(_CTCP_ESC, false):
			if part.begins_with("CLIENTINFO") or part.begins_with("DCC"):
				ctcp.append(part.split(" ", false))
			else:
				ctcp.append(part.split(" ", false, 1))

	ordinal = _MAPPING.get(cmd, cmd.to_int())
	_FINALIZERS.get(ordinal, _noop_finalizer).call(self)


func get_source() -> String:
	var source = parsed.get(&"source")
	if source != null:
		if source.has("nick"):
			return source.get("nick")
		return source.get("server", "")
	return ""


func get_text() -> String:
	return parsed.get(&"text", "")


func get_target() -> String:
	return parsed.get(&"target", "")


func get_arg_count() -> int:
	return parsed.get(&"positional", _EMPTY).size()


func get_arg(idx: int) -> String:
	var args: PackedStringArray = parsed.get(&"positional", _EMPTY)
	if args.size() > idx:
		return args[idx]
	return ""


func _parse_source(raw: String) -> Dictionary:
	var result := {}
	if not raw.is_empty():
		var parts := SRC_REGEX.search(raw)
		var part := parts.get_string("host")
		if not part.is_empty():
			result["host"] = part.substr(1)
		part = parts.get_string("user")
		if not part.is_empty():
			result["user"] = part.substr(1)
		part = parts.get_string("nick")
		if not part.is_empty():
			result[ "server" if part.contains(".") else "nick"] = part.substr(1)

	return result


func _parse_tags(raw: String) -> Dictionary:
	var result := {}
	if not raw.is_empty():
		for tag: String in raw.split(";", false):
			var parts := TAG_REGEX.search(tag)
			var val := parts.get_string("value")
			if val.is_empty():
				result[parts.get_string("key")] = null
			else:
				result[parts.get_string("key")] = parts.get_string("value").substr(1)

	return result


static func _noop_finalizer(event: IrcEvent) -> void:
	# nothing to do
	event.valid = false


static func _cap_finalizer(event: IrcEvent) -> void:
	if event.sub_cmds.is_empty():
		event.valid = false
		return
	var idx := event.sub_cmds.size() - 1
	var partial := event.sub_cmds[idx] == "*"
	event.parsed[&"partial"] = partial
	if partial:
		idx -= 1
	event.parsed[&"sub"] = event.sub_cmds[idx]
	event.parsed[&"caps"] = event.args.slice(1) if event.args[0] == ":" else event.args
	event.valid = true


static func _bare_finalizer(event: IrcEvent) -> void:
	# nothing to do
	event.valid = true


static func _text_only_finalizer(event: IrcEvent) -> void:
	event.valid = not event.args.is_empty()
	if event.valid:
		match event.args.size():
			1:
				event.parsed[&"text"] = event.args[0]
			_:
				var idx := event.args.size() - 2
				if event.args[idx] == ":":
					event.parsed[&"text"] = event.args[idx + 1]
				else:
					event.parsed[&"text"] = ""


static func _targeted_text_only_finalizer(event: IrcEvent) -> void:
	var idx := event.args.size() - 2
	event.valid = idx >= 0
	if event.valid:
		event.parsed[&"target"] = event.args[0]
		if idx == 0:
			event.parsed[&"text"] = event.args[1]
		else:
			event.parsed[&"text"] = event.args[idx + 1]


static func _text_last_finalizer(event: IrcEvent) -> void:
	event.valid = not event.args.is_empty()
	if event.valid:
		match event.args.size():
			1:
				event.parsed[&"text"] = event.args[0]
				event.parsed[&"positional"] = _EMPTY
			_:
				var idx := event.args.size() - 2
				if event.args[idx] == ":":
					event.parsed[&"text"] = event.args[idx + 1]
					event.parsed[&"positional"] = event.args.slice(0, idx)
				elif event.args[idx + 1] == ":":
					event.parsed[&"text"] = ""
					event.parsed[&"positional"] = event.args.slice(0, idx + 1)
				else:
					event.parsed[&"text"] = event.args[idx + 1]
					event.parsed[&"positional"] = event.args.slice(0, idx + 1)


static func _simple_finalizer(event: IrcEvent) -> void:
	event.parsed[&"positional"] = event.args
	event.valid = true


static func _targeted_simple_finalizer(event: IrcEvent) -> void:
	if not event.args.is_empty():
		event.parsed[&"target"] = event.args[0]
	if event.args.size() > 1:
		event.parsed[&"positional"] = event.args.slice(1)
	event.valid = true


static func _optional_text_finalizer(event: IrcEvent) -> void:
	match event.args.size():
		0:
			event.parsed[&"text"] = ""
			event.valid = true
		1:
			event.parsed[&"text"] = "" if event.args[0] == ":" else event.args[0]
			event.valid = true
		2:
			event.valid = event.args[0] == ":"
			if event.valid:
				event.parsed[&"text"] = event.args[1]
		_:
			event.valid = false


static func _simple_with_optional_text_finalizer(event: IrcEvent) -> void:
	var idx := event.args.size() - 2
	if idx >= 0:
		if event.args[idx] == ":":
			event.parsed[&"text"] = event.args[idx + 1]
			event.parsed[&"positional"] = event.args.slice(0, idx)
		elif event.args[idx + 1] == ":":
			event.parsed[&"text"] = ""
			event.parsed[&"positional"] = event.args.slice(0, idx + 1)
		else:
			event.parsed[&"positional"] = event.args
		event.valid = true
	else:
		event.valid = not event.args.is_empty()
		event.parsed[&"positional"] = event.args


static func _targeted_simple_with_optional_text_finalizer(event: IrcEvent) -> void:
	var idx := event.args.size() - 2
	if idx >= 0:
		if event.args[idx] == ":":
			event.parsed[&"text"] = event.args[idx + 1]
			event.parsed[&"positional"] = event.args.slice(1, idx)
		else:
			event.parsed[&"text"] = ""
			event.parsed[&"positional"] = event.args.slice(1, idx + (1 if event.args[idx + 1] == ":" else 2))
		event.parsed[&"target"] = event.args[0]
		event.valid = true
	else:
		event.valid = not event.args.is_empty()
		if event.valid:
			event.parsed[&"target"] = event.args[0]
			event.parsed[&"positional"] = event.args.slice(1)
		else:
			event.parsed[&"positional"] = _EMPTY


static func _privmsg_finalizer(event: IrcEvent) -> void:
	if event.ctcp.is_empty():
		event.valid = not event.args.is_empty()
		if event.valid:
			match event.args.size():
				1:
					event.parsed[&"positional"] = _EMPTY
				_:
					var idx := event.args.size() - 2
					if event.args[idx] == ":":
						event.parsed[&"text"] = event.args[idx + 1]
						event.parsed[&"positional"] = event.args.slice(1, idx)
					elif event.args[idx + 1] == ":":
						event.parsed[&"text"] = ""
						event.parsed[&"positional"] = event.args.slice(1, idx + 1)
					else:
						event.parsed[&"text"] = event.args[idx + 1]
						event.parsed[&"positional"] = event.args.slice(1, idx + 1)
			event.parsed[&"target"] = event.args[0]
	else:
		event.valid = not event.args.is_empty()
		if event.valid:
			event.parsed[&"target"] = event.args[0]
			event.parsed[&"positional"] = event.args.slice(1)
