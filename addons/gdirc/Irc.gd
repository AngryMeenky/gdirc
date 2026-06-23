# REFERENCE: https://modern.ircdocs.horse/
extends Node
class_name IRC


signal conn_closed()
signal conn_established()
signal conn_error(err: String)
signal irc_event(event: Event)
signal irc_established()


enum Status {
	STATUS_DISCONNECTED,
	STATUS_CONNECTING,
	STATUS_CONNECTED,
	STATUS_ERROR,
	STATUS_ERROR_HOSTNAME_MISMATCH,
	STATUS_CLOSING,
	STATUS_REGISTERING,
	STATUS_REGISTERED
}


enum Commands {
	CAP     =  -1, AUTHENTICATE =  -2, PASS     =  -3, NICK    =  -4,
	USER    =  -5, PING         =  -6, PONG     =  -7, OPER    =  -8,
	QUIT    =  -9, ERROR        = -10, JOIN     = -11, PART    = -12,
	TOPIC   = -13, NAMES        = -14, LIST     = -15, INVITE  = -16,
	KICK    = -17, MOTD         = -18, VERSION  = -19, ADMIN   = -20,
	CONNECT = -21, LUSERS       = -22, TIME     = -23, STATS   = -24,
	HELP    = -25, INFO         = -26, MODE     = -27, PRIVMSG = -28,
	NOTICE  = -29, WHO          = -30, WHOIS    = -31, WHOWAS  = -32,
	KILL    = -33, REHASH       = -34, RESTART  = -35, SQUIT   = -36,
	AWAY    = -37, LINKS        = -38, USERHOST = -39, WALLOPS = -40,

	RPL_WELCOME  = 1, RPL_YOURHOST =  2, RPL_CREATED = 3, RPL_MYINFO = 4,
	RPL_ISUPPORT = 5, RPL_BOUNCE   = 10,
	
	RPL_STATSCOMMANDS = 212, RPL_ENDOFSTATS    = 219, RPL_UMODEIS       = 221,
	RPL_STATSUPTIME   = 242, RPL_STATSCONN     = 250, RPL_LUSERCLIENT   = 251,
	RPL_LUSEROP       = 252, RPL_LUSERUNKNOWN  = 253, RPL_LUSERCHANNELS = 254,
	RPL_LUSERME       = 255, RPL_ADMINME       = 256, RPL_ADMINLOC1     = 257,
	RPL_ADMINLOC2     = 258, RPL_ADMINEMAIL    = 259, RPL_TRYAGAIN      = 263,
	RPL_LOCALUSERS    = 265, RPL_GLOBALUSERS   = 266, RPL_WHOISCERTFP   = 276,
	
	RPL_NONE          = 300, RPL_AWAY            = 301, RPL_USERHOST       = 302,
	RPL_UNAWAY        = 305, RPL_NOWAWAY         = 306, RPL_WHOISREGNICK   = 307,
	RPL_WHOISUSER     = 311, RPL_WHOISSERVER     = 312, RPL_WHOISOPERATOR  = 313,
	RPL_WHOWASUSER    = 314, RPL_ENDOFWHO        = 315, RPL_WHOISIDLE      = 317,
	RPL_ENDOFWHOIS    = 318, RPL_WHOISCHANNELS   = 319, RPL_WHOISSPECIAL   = 320,
	RPL_LISTSTART     = 321, RPL_LIST            = 322, RPL_LISTEND        = 323,
	RPL_CHANNELMODEIS = 324, RPL_CREATIONTIME    = 329, RPL_WHOISACCOUNT   = 330,
	RPL_NOTOPIC       = 331, RPL_TOPIC           = 332, RPL_TOPICWHOTIME   = 333,
	RPL_INVITELIST    = 336, RPL_ENDOFINVITELIST = 337, RPL_WHOISACTUALLY  = 338,
	RPL_INVITING      = 341, RPL_INVEXLIST       = 346, RPL_ENDOFINVEXLIST = 347,
	RPL_EXCEPTLIST    = 348, RPL_ENDOFEXCEPTLIST = 349, RPL_VERSION        = 351,
	RPL_WHOREPLY      = 352, RPL_NAMREPLY        = 353, RPL_LINKS          = 364,
	RPL_ENDOFLINKS    = 365, RPL_ENDOFNAMES      = 366, RPL_BANLIST        = 367,
	RPL_ENDOFBANLIST  = 368, RPL_ENDOFWHOWAS     = 369, RPL_INFO           = 371,
	RPL_MOTD          = 372, RPL_ENDOFINFO       = 374, RPL_MOTDSTART      = 375,
	RPL_ENDOFMOTD     = 376, RPL_WHOISHOST       = 378, RPL_WHOISMODES     = 379,
	RPL_YOUREOPER     = 381, RPL_REHASHING       = 382, RPL_TIME           = 391,

	ERR_UNKNOWNERROR     = 400, ERR_NOSUCHNICK        = 401, ERR_NOSUCHSERVER     = 402,
	ERR_NOSUCHCHANNEL    = 403, ERR_CANNOTSENDTOCHAN  = 404, ERR_TOOMANYCHANNELS  = 405,
	ERR_WASNOSUCHNICK    = 406, ERR_NOORIGIN          = 409, ERR_NORECIPIENT      = 411,
	ERR_NOTEXTTOSEND     = 412, ERR_INPUTTOOLONG      = 417, ERR_UNKNOWNCOMMAND   = 421,
	ERR_NOMOTD           = 422, ERR_NONICKNAMEGIVEN   = 431, ERR_ERRONEUSNICKNAME = 432,
	ERR_NICKNAMEINUSE    = 433, ERR_NICKCOLLISION     = 436, ERR_USERNOTINCHANNEL = 441,
	ERR_NOTONCHANNEL     = 442, ERR_USERONCHANNEL     = 443, ERR_NOTREGISTERED    = 451,
	ERR_NEEDMOREPARAMS   = 461, ERR_ALREADYREGISTERED = 462, ERR_PASSWDMISMATCH   = 464,
	ERR_YOUREBANNEDCREEP = 465, ERR_CHANNELISFULL     = 471, ERR_UNKNOWNMODE      = 472,
	ERR_INVITEONLYCHAN   = 473, ERR_BANNEDFROMCHAN    = 474, ERR_BADCHANNELKEY    = 475,
	ERR_BADCHANMASK      = 476, ERR_NOPRIVILEGES      = 481, ERR_CHANOPRIVSNEEDED = 482,
	ERR_CANTKILLSERVER   = 483, ERR_NOOPERHOST        = 491,

	ERR_UMODEUNKNOWNFLAG = 501, ERR_USERSDONTMATCH = 502,
	ERR_HELPNOTFOUND     = 524, ERR_INVALIDKEY     = 525,

	RPL_STARTTLS = 670, RPL_WHOISSECURE      = 671,
	ERR_STARTTLS = 691, ERR_INVALIDMODEPARAM = 696,
	
	RPL_HELPSTART = 704, RPL_HELPTXT = 705,
	RPL_ENDOFHELP = 706, ERR_NOPRIVS = 723,

	RPL_LOGGEDIN    = 900, RPL_LOGGEDOUT   = 901, ERR_NICKLOCKED  = 902,
	RPL_SASLSUCCESS = 903, ERR_SASLFAIL    = 904, ERR_SASLTOOLONG = 905,
	ERR_SASLABORTED = 906, ERR_SASLALREADY = 907, RPL_SASLMECHS   = 908,
}


const CTCP_ESC := "\u0001"
const ENDL: PackedByteArray = [ 0x0D, 0x0A ]
static var ADDR_REGEX := RegEx.create_from_string(
	"(?<scheme>ircs?|wss?)://(?<host>[0-9.]+|[^:]+|\\[[:0-9A-Fa-f]+\\])(?<port>:\\d+)?"
)


@export var network  := "irc.example.local"
@export var nick     := "godot"
@export var user     := "godot"
@export var password := ""
@export var debug := false:
	set(val):
		_wrapper.debug = val
		if _client != null:
			_client._debug = val
		debug = val

var _connected := false
var _client: Client = null
var _wrapper = StubWrapper.new()


func _init():
	_wrapper.debug = debug
	_wrapper.conn_error.connect(_on_error)
	_wrapper.conn_closed.connect(_on_close)
	_wrapper.conn_established.connect(_on_connect)


func _ready() -> void:
	_client = Client.new(nick, user, password, network)
	_client.conn_established.connect(_on_established)
	_client._debug = debug


func _process(_delta):
	if _wrapper.get_status() == Status.STATUS_CONNECTED:
		# send any automatic responses
		while _client.get_response_count() > 0:
			var packet := _client.get_response()
			if debug:
				print(">>> ", packet.trim_suffix("\r\n"))
			_wrapper.put_packet(packet)

	# check for input
	_wrapper.poll()
	while _wrapper.get_available_packet_count() > 0:
		var packet: String = _wrapper.get_packet()
		if debug:
			print("<<< ", packet)
		var event = _client.process(packet)
		if event != null:
			irc_event.emit(event)


func set_connection(conn) -> Error:
	var old = _wrapper

	if conn is StreamPeerTCP:
		_wrapper = TcpWrapper.new(conn)
		_wrapper.debug = debug
		_client.reset()
	elif conn is StreamPeerTLS:
		_wrapper = TlsWrapper.new(conn)
		_wrapper.debug = debug
		_client.reset()
	elif conn is WebSocketWrapper:
		_wrapper = WebSocketWrapper.new(conn)
		_wrapper.debug = debug
		_client.reset()
	else:
		push_error("Invalid connection type: ", conn.get_class())
		return ERR_CANT_CREATE

	# swap the signal connections
	old.conn_error.disconnect(_on_error)
	old.conn_closed.disconnect(_on_close)
	old.conn_established.disconnect(_on_connect)

	_wrapper.conn_error.connect(_on_error)
	_wrapper.conn_closed.connect(_on_close)
	_wrapper.conn_established.connect(_on_connect)

	return OK


func connect_to_server(url: String) -> Error:
	var err := ERR_INVALID_DATA
	var parts := ADDR_REGEX.search(url)
	if parts != null:
		match parts.get_string("scheme"):
			"irc": # TCP
				var stream := StreamPeerTCP.new()
				var port := parts.get_string("port").to_int()
				err = stream.connect_to_host(parts.get_string("host"), port if port > 0 else 6667)
				if err == OK:
					set_connection(stream)
				else:
					push_error("Failure to connect to host: ", url)
			"ircs": # TLS
				var tcp := StreamPeerTCP.new()
				var port := parts.get_string("port").to_int()
				err = tcp.connect_to_host(parts.get_string("host"), port if port > 0 else 6697)
				if err == OK:
					var tls := StreamPeerTLS.new()
					err = tls.connect_to_stream(tcp, parts.get_string("host"), TLSOptions.client_unsafe())
					if err == OK:
						set_connection(tls)
					else:
						push_error("Failure to connect to host: ", url)
				else:
					push_error("Failure to connect to host: ", url)
			"ws": # WebSocket
				var ws := WebSocketPeer.new()
				err = ws.connect_to_url(url)
				if err == OK:
					set_connection(ws)
				else:
					push_error("Failure to connect websocket: ", url)
			"wss": # WebSocket + TLS
				var ws := WebSocketPeer.new()
				err = ws.connect_to_url(url)
				if err == OK:
					set_connection(ws)
				else:
					push_error("Failure to connect websocket: ", url)
			_:
				push_error("Unrecognized uri: ", url)
	else:
		push_error("Unparsable uri: ", url)

	return err


func _on_error(err: String) -> void:
	conn_error.emit(err)


func _on_close() -> void:
	conn_closed.emit()


func _on_connect() -> void:
	conn_established.emit()


func _on_established() -> void:
	irc_established.emit()


class StubWrapper:
	signal conn_closed()
	signal conn_established()
	signal conn_error(err: String)


	@export var debug := false


	func poll() -> void:
		print("StubWrapper.poll()")
		pass


	func get_status() -> Status:
		return Status.STATUS_DISCONNECTED


	func get_available_packet_count() -> int:
		return 0


	func get_packet() -> String:
		return ""


	func get_packet_error() -> Error:
		return ERR_DOES_NOT_EXIST


	func put_packet(packet: String) -> Error:
		return ERR_LINK_FAILED


class TcpWrapper:
	signal conn_closed()
	signal conn_established()
	signal conn_error(err: String)


	@export var debug := false

	var _tcp: StreamPeerTCP = null
	var _queue: PackedStringArray = []
	var _buffer: PackedByteArray = []
	var _status := StreamPeerTCP.STATUS_NONE


	func _init(tcp: StreamPeerTCP):
		assert(tcp != null, "StreamPeerTCP is null")
		_tcp = tcp
		_status = tcp.get_status()


	func poll() -> void:
		_tcp.poll()
		# check status and emit signals on change
		var status := _tcp.get_status()
		if status != _status:
			_status = status
			match status:
				StreamPeerTCP.STATUS_NONE:
					conn_closed.emit()
				StreamPeerTCP.STATUS_CONNECTED:
					conn_established.emit()
				StreamPeerTCP.STATUS_ERROR:
					conn_error.emit("TCP connection error")
					_tcp.disconnect_from_host()

		# try to read and parse lines
		if _status == StreamPeerTCP.STATUS_CONNECTED:
			var avail := _tcp.get_available_bytes()
			if avail > 0:
				var data := _tcp.get_data(avail)
				# Check for read error.
				if data[0] != OK:
					conn_error.emit("TCP Error getting data from stream: " + str(data[0]))
				else:
					_buffer.append_array(data[1])
					var base := 0
					while true:
						var rIdx := _buffer.find(0x0D, base) # '\r'
						var nIdx := _buffer.find(0x0A, base) # '\n'
						if rIdx >= 0:
							_queue.append(_buffer.slice(base, rIdx).get_string_from_utf8())
							base = (nIdx if nIdx == rIdx + 1 else rIdx) + 1
						elif nIdx >= 0:
							_queue.append(_buffer.slice(base, nIdx).get_string_from_utf8())
							base = nIdx + 1
						else:
							if base < _buffer.size():
								_buffer = _buffer.slice(base) # trim the buffer
							else:
								_buffer.clear() # eveything was used
							break


	func get_status() -> Status:
		return _tcp.get_status() as Status


	func get_available_packet_count() -> int:
		return _queue.size()


	func get_packet() -> String:
		if _queue.is_empty():
			return ""
		var line := _queue[0]
		_queue.remove_at(0)
		return line


	func get_packet_error() -> Error:
		return ERR_DOES_NOT_EXIST


	func put_packet(packet: String) -> Error:
		var data := packet.to_utf8_buffer()
		if not packet.ends_with("\r\n"):
			data.append_array(ENDL)
		return _tcp.put_data(data)


class TlsWrapper:
	signal conn_closed()
	signal conn_established()
	signal conn_error(err: String)


	@export var debug := false

	var _tls: StreamPeerTLS = null
	var _queue: PackedStringArray = []
	var _buffer: PackedByteArray = []
	var _status := StreamPeerTLS.STATUS_DISCONNECTED


	func _init(tls: StreamPeerTLS):
		assert(tls != null, "StreamPeerTLS is null")
		_tls = tls
		_status = tls.get_status()


	func poll() -> void:
		_tls.poll()
		# check status and emit signals on change
		var status := _tls.get_status()
		if status != _status:
			_status = status
			match status:
				StreamPeerTLS.STATUS_DISCONNECTED:
					conn_closed.emit()
				StreamPeerTLS.STATUS_CONNECTED:
					conn_established.emit()
				StreamPeerTLS.STATUS_ERROR:
					conn_error.emit("TLS connection error")
					_tls.disconnect_from_stream()
				StreamPeerTLS.STATUS_ERROR_HOSTNAME_MISMATCH:
					conn_error.emit("TLS connection error: Hostname mismatch")
					_tls.disconnect_from_stream()

		# try to read and parse lines
		if _status == StreamPeerTLS.STATUS_CONNECTED:
			var avail := _tls.get_available_bytes()
			if avail > 0:
				var data := _tls.get_data(avail)
				# Check for read error.
				if data[0] != OK:
					conn_error.emit("TLS Error getting data from stream: " + str(data[0]))
				else:
					_buffer.append_array(data[1])
					var base := 0
					while true:
						var rIdx := _buffer.find(0x0D, base) # '\r'
						var nIdx := _buffer.find(0x0A, base) # '\n'
						if rIdx >= 0:
							_queue.append(_buffer.slice(base, rIdx).get_string_from_utf8())
							base = (nIdx if nIdx == rIdx + 1 else rIdx) + 1
						elif nIdx >= 0:
							_queue.append(_buffer.slice(base, nIdx).get_string_from_utf8())
							base = nIdx + 1
						else:
							if base < _buffer.size():
								_buffer = _buffer.slice(base) # trim the buffer
							else:
								_buffer.clear() # eveything was used
							break


	func get_status() -> Status:
		return _tls.get_status() as Status


	func get_available_packet_count() -> int:
		return _queue.size()


	func get_packet() -> String:
		if _queue.is_empty():
			return ""
		var line := _queue[0]
		_queue.remove_at(0)
		return line


	func get_packet_error() -> Error:
		return ERR_DOES_NOT_EXIST


	func put_packet(packet: String) -> Error:
		var data := packet.to_utf8_buffer()
		if not packet.ends_with("\r\n"):
			data.append_array(ENDL)
		return _tls.put_data(data)


class WebSocketWrapper:
	signal conn_closed()
	signal conn_established()
	signal conn_error(err: String)


	@export var debug := false

	var _ws: WebSocketPeer = null
	var _queue: PackedStringArray = []
	var _buffer: PackedByteArray = []
	var _status := WebSocketPeer.STATE_CONNECTING


	func _init(ws: WebSocketPeer):
		assert(ws != null, "WebSocketPeer is null")
		_ws = ws
		_status = _ws.get_ready_state()


	func poll() -> void:
		_ws.poll()
		var status := _ws.get_ready_state()
		if status != _status:
			status = _status
			match status:
				WebSocketPeer.STATE_OPEN:
					conn_established.emit()
				WebSocketPeer.STATE_CLOSED:
					conn_closed.emit()

		if _status == WebSocketPeer.STATE_OPEN:
			while _ws.get_available_packet_count() > 0:
				var packet := _ws.get_packet()
				if not packet.is_empty():
					_buffer.append_array(packet)
					var base := 0
					while true:
						var rIdx := _buffer.find(0x0D, base) # '\r'
						var nIdx := _buffer.find(0x0A, base) # '\n'
						if rIdx >= 0:
							_queue.append(_buffer.slice(base, rIdx).get_string_from_utf8())
							base = (nIdx if nIdx == rIdx + 1 else rIdx) + 1
						elif nIdx >= 0:
							_queue.append(_buffer.slice(base, nIdx).get_string_from_utf8())
							base = nIdx + 1
						else:
							if base < _buffer.size():
								_buffer = _buffer.slice(base) # trim the buffer
							else:
								_buffer.clear() # eveything was used
							break


	func get_status() -> Status:
		match _ws.get_ready_state():
			WebSocketPeer.STATE_CONNECTING:
				return Status.STATUS_CONNECTING
			WebSocketPeer.STATE_OPEN:
				return Status.STATUS_CONNECTED
			WebSocketPeer.STATE_CLOSING:
				return Status.STATUS_CLOSING
			WebSocketPeer.STATE_CLOSED, _:
				return Status.STATUS_DISCONNECTED


	func get_available_packet_count() -> int:
		return _queue.size()


	func get_packet() -> String:
		if _queue.is_empty():
			return ""
		var line := _queue[0]
		_queue.remove_at(0)
		return line


	func get_packet_error() -> Error:
		return _ws.get_packet_error()


	func put_packet(packet: String) -> Error:
		if not packet.ends_with("\r\n"):
			packet += "\r\n"
		return _ws.send_text(packet)


class Client:
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


	func process(raw: String) -> Event:
		# bail on empty string
		if raw.is_empty():
			return null
	
		var res := REGEX.search(raw)
		if res == null or res.get_group_count() == 0:
			return null

		var event: Event = PARSERS.get(res.get_string("command").to_upper(), _parse_text_cmd).call(res, _debug)
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
			_queue.append(":%s PONG %s" % event.args[0])
		return event


	func _negotiate(event: Event) -> void:
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
					print("Negotiating complete")
				elif event.ordinal == IRC.Commands.ERR_NICKNAMEINUSE:
					_nick += "_"
					_queue.append("NICK %s" % _nick)


	func _handle_ctcp_request(event: Event) -> void:
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


	func _handle_ctcp_response(event: Event) -> void:
		# TODO: handle the responses
		pass


	static func _dump_parts(parts: RegExMatch) -> void:
		print("Event: ", parts.subject)
		for key in parts.names.keys():
			print("  ", key, ": ", parts.get_string(key))


	static func _parse_no_args_cmd(parts: RegExMatch, debug: bool) -> Event:
		if debug:
			_dump_parts(parts)
		var tags := parts.get_string("tags")
		var src  := parts.get_string("source")
		var cmd  := parts.get_string("command")
		var args: PackedStringArray = []

		return Event.new(tags, src, cmd, args)


	static func _parse_one_arg_cmd(parts: RegExMatch, debug: bool) -> Event:
		if debug:
			_dump_parts(parts)
		var tags := parts.get_string("tags")
		var src  := parts.get_string("source")
		var cmd  := parts.get_string("command")
		var args: PackedStringArray = [ parts.get_string("args") ]

		if args[0].is_empty():
			args.clear()

		return Event.new(tags, src, cmd, args)


	static func _parse_cap(parts: RegExMatch, debug: bool) -> Event:
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

		return Event.new(tags, src, cmd, args, subs)


	static func _parse_text_cmd(parts: RegExMatch, debug: bool) -> Event:
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

		return Event.new(tags, src, cmd, args)


	static func _parse_simple_cmd(parts: RegExMatch, debug: bool) -> Event:
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

		return Event.new(tags, src, cmd, args)


class Event:
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


	static func _noop_finalizer(event: Event) -> void:
		# nothing to do
		event.valid = false


	static func _cap_finalizer(event: Event) -> void:
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


	static func _bare_finalizer(event: Event) -> void:
		# nothing to do
		event.valid = true


	static func _text_only_finalizer(event: Event) -> void:
		event.valid = not event.args.is_empty()
		if event.valid:
			event.parsed[&"text"] = event.args[1] if event.args[0] == ":" else event.args[0]


	static func _text_last_finalizer(event: Event) -> void:
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


	static func _simple_finalizer(event: Event) -> void:
		event.parsed[&"positional"] = event.args
		event.valid = true


	static func _optional_text_finalizer(event: Event) -> void:
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


	static func _simple_with_optional_text_finalizer(event: Event) -> void:
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


	static func _privmsg_finalizer(event: Event) -> void:
		if event.ctcp.is_empty():
			_text_last_finalizer(event)
		else:
			event.valid = true
