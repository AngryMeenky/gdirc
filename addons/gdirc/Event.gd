extends RefCounted
class_name IrcEvent

static var SRC_REGEX := RegEx.create_from_string("(?<nick>[^!]+)(?<user>![^@]+)?(?<host>@.+)?")
static var TAG_REGEX := RegEx.create_from_string("(?<key>[^=]+)(?<value>=[^\\r\\n; ])?")
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
	IRC.Commands.QUIT:         _optional_text_finalizer,
	IRC.Commands.ERROR:        _optional_text_finalizer,
	IRC.Commands.PART:         _simple_with_optional_text_finalizer,
	IRC.Commands.TOPIC:        _simple_with_optional_text_finalizer,
	IRC.Commands.NAMES:        _simple_finalizer,
	IRC.Commands.LIST:         _simple_finalizer,
	IRC.Commands.INVITE:       _simple_finalizer,
	IRC.Commands.KICK:         _simple_with_optional_text_finalizer,
	IRC.Commands.MOTD:         _simple_finalizer,
	IRC.Commands.VERSION:      _simple_finalizer,
	IRC.Commands.ADMIN:        _simple_finalizer,
	IRC.Commands.CONNECT:      _simple_finalizer,
	IRC.Commands.LUSERS:       _bare_finalizer,
	IRC.Commands.TIME:         _simple_finalizer,
	IRC.Commands.STATS:        _simple_finalizer,
	IRC.Commands.HELP:         _simple_with_optional_text_finalizer,
	IRC.Commands.INFO:         _bare_finalizer,
	IRC.Commands.MODE:         _simple_finalizer,
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

	IRC.Commands.RPL_WELCOME:  _text_only_finalizer,
	IRC.Commands.RPL_YOURHOST: _text_only_finalizer,
	IRC.Commands.RPL_CREATED:  _text_only_finalizer,
	IRC.Commands.RPL_MYINFO:   _simple_finalizer,
	IRC.Commands.RPL_ISUPPORT: _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_BOUNCE:   _simple_with_optional_text_finalizer,

	IRC.Commands.RPL_STATSCOMMANDS: _simple_finalizer,
	IRC.Commands.RPL_ENDOFSTATS:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_UMODEIS:       _simple_finalizer,
	IRC.Commands.RPL_STATSUPTIME:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_STATSCONN:     _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERCLIENT:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSEROP:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERUNKNOWN:  _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERCHANNELS: _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LUSERME:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINME:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINLOC1:     _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINLOC2:     _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ADMINEMAIL:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TRYAGAIN:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LOCALUSERS:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_GLOBALUSERS:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISCERTFP:   _simple_with_optional_text_finalizer,

	IRC.Commands.RPL_AWAY:            _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_USERHOST:        _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_UNAWAY:          _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_NOWAWAY:         _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISREGNICK:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISUSER:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISSERVER:     _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISOPERATOR:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOWASUSER:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFWHO:        _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISIDLE:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFWHOIS:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISCHANNELS:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISSPECIAL:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LISTSTART:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LIST:            _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LISTEND:         _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_CHANNELMODEIS:   _simple_finalizer,
	IRC.Commands.RPL_CREATIONTIME:    _simple_finalizer,
	IRC.Commands.RPL_WHOISACCOUNT:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_NOTOPIC:         _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TOPIC:           _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TOPICWHOTIME:    _simple_finalizer,
	IRC.Commands.RPL_INVITELIST:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFINVITELIST: _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISACTUALLY:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_INVITING:        _simple_finalizer,
	IRC.Commands.RPL_INVEXLIST:       _simple_finalizer,
	IRC.Commands.RPL_ENDOFINVEXLIST:  _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_EXCEPTLIST:      _simple_finalizer,
	IRC.Commands.RPL_ENDOFEXCEPTLIST: _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_VERSION:         _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOREPLY:        _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_NAMREPLY:        _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LINKS:           _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFLINKS:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFNAMES:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_BANLIST:         _simple_finalizer,
	IRC.Commands.RPL_ENDOFBANLIST:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFWHOWAS:     _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_INFO:            _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_MOTD:            _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFINFO:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_MOTDSTART:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFMOTD:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISHOST:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISMODES:      _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_YOUREOPER:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_REHASHING:       _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_TIME:            _simple_with_optional_text_finalizer,

	IRC.Commands.ERR_UNKNOWNERROR:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOSUCHNICK:        _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOSUCHSERVER:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOSUCHCHANNEL:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CANNOTSENDTOCHAN:  _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_TOOMANYCHANNELS:   _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_WASNOSUCHNICK:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOORIGIN:          _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NORECIPIENT:       _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOTEXTTOSEND:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INPUTTOOLONG:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_UNKNOWNCOMMAND:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOMOTD:            _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NONICKNAMEGIVEN:   _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_ERRONEUSNICKNAME:  _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NICKNAMEINUSE:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NICKCOLLISION:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_USERNOTINCHANNEL:  _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOTONCHANNEL:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_USERONCHANNEL:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOTREGISTERED:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NEEDMOREPARAMS:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_ALREADYREGISTERED: _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_PASSWDMISMATCH:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_YOUREBANNEDCREEP:  _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CHANNELISFULL:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_UNKNOWNMODE:       _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INVITEONLYCHAN:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_BANNEDFROMCHAN:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_BADCHANNELKEY:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_BADCHANMASK:       _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOPRIVILEGES:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CHANOPRIVSNEEDED:  _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_CANTKILLSERVER:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOOPERHOST:        _simple_with_optional_text_finalizer,

	IRC.Commands.ERR_UMODEUNKNOWNFLAG: _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_USERSDONTMATCH:   _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_HELPNOTFOUND:     _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INVALIDKEY:       _simple_with_optional_text_finalizer,

	IRC.Commands.RPL_STARTTLS:         _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_WHOISSECURE:      _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_STARTTLS:         _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_INVALIDMODEPARAM: _simple_with_optional_text_finalizer,

	IRC.Commands.RPL_HELPSTART: _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_HELPTXT:   _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_ENDOFHELP: _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NOPRIVS:   _simple_with_optional_text_finalizer,

	IRC.Commands.RPL_LOGGEDIN:    _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_LOGGEDOUT:   _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_NICKLOCKED:  _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_SASLSUCCESS: _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLFAIL:    _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLTOOLONG: _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLABORTED: _simple_with_optional_text_finalizer,
	IRC.Commands.ERR_SASLALREADY: _simple_with_optional_text_finalizer,
	IRC.Commands.RPL_SASLMECHS:   _simple_with_optional_text_finalizer,
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
	if args.size() == 2 and args[1].begins_with(IRC.CTCP_ESC) and (cmd == "NOTICE" or cmd == "PRIVMSG"):
		for part: String in args[1].split(IRC.CTCP_ESC, false):
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
			result[ "server" if part.contains(".") else "nick"] = part

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
		event.parsed[&"text"] = event.args[1] if event.args[0] == ":" else event.args[0]


static func _text_last_finalizer(event: IrcEvent) -> void:
	event.valid = not event.args.is_empty()
	if event.valid:
		match event.args.size():
			1:
				event.parsed[&"text"] = event.args[0]
				var empty: PackedVector2Array = []
				event.parsed[&"positional"] = empty
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
		event.parsed[&"positional"] = event.args
		event.valid = not event.args.is_empty()


static func _privmsg_finalizer(event: IrcEvent) -> void:
	if event.ctcp.is_empty():
		_text_last_finalizer(event)
	else:
		event.valid = true
