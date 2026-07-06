# REFERENCE: https://modern.ircdocs.horse/
extends Node
class_name IRC


signal conn_closed()
signal conn_established()
signal conn_error(err: String)
signal irc_event(event: IrcEvent)
signal irc_established()
signal upnp_completed(result: int)


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


const ENDL: PackedByteArray = [ 0x0D, 0x0A ] # "\r\n" in byte form
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
var _upnp := UPNP.new()
var _client: IrcClient = null
var _upnp_thread: Thread = null
var _wrapper: BackendWrapper = BackendWrapper.new()
var _local_ip := "127.0.0.1"
var _public_ip := "127.0.0.1"


func _init():
	_wrapper.debug = debug
	_wrapper.conn_error.connect(_on_error)
	_wrapper.conn_closed.connect(_on_close)
	_wrapper.conn_established.connect(_on_connect)


func _ready() -> void:
	_client = IrcClient.new(nick, user, password, network)
	_client.conn_established.connect(_on_established)
	_client._debug = debug
	initiate_upnp_scan()


func _process(_delta):
	if _wrapper.get_status() == Status.STATUS_CONNECTED:
		# send any automatic responses and queued messages
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


func _discovery_worker() -> void:
	# attempt to determine at least some semi usable IPs
	var addr := _get_non_loopback()
	if _local_ip == "127.0.0.1":
		_local_ip = addr

	if _public_ip == "127.0.0.1":
		_public_ip = addr

	var result := _upnp.discover()
	_discovery_complete.call_deferred(result)


func _discovery_complete(result: int) -> void:
	_upnp_thread.wait_to_finish()
	_upnp_thread = null
	if result == UPNP.UPNP_RESULT_SUCCESS:
		var gateway := _upnp.get_gateway()
		if gateway and gateway.is_valid_gateway():
			_local_ip = gateway.igd_our_addr
			_public_ip = gateway.query_external_address()
	upnp_completed.emit(result)


func _add_port_worker(port: int, proto: String) -> void:
	var result := _upnp.add_port_mapping(port, port, "gdIRC", proto, 120)
	_port_change_complete.call_deferred(result)


func _remove_port_worker(port: int, proto: String) -> void:
	var result := _upnp.delete_port_mapping(port, proto)
	_port_change_complete.call_deferred(result)


func _port_change_complete(result: int) -> void:
	_upnp_thread.wait_to_finish()
	_upnp_thread = null
	upnp_completed.emit(result)


func _get_non_loopback() -> String:
	var prefix := RegEx.create_from_string("10\\.|192\\.168\\.") # ignore typical docker networks
	for addr: String in IP.get_local_addresses():
		var m := prefix.search(addr)
		if m != null:
			return m.subject

	return "127.0.0.1" # complete failure fallback


func _raw_ip_to_dcc_ip(addr: String) -> String:
	var parts := addr.split(".", false)
	if parts.size() == 4:
		return str((int(parts[0]) << 24) | (int(parts[1]) << 16) | (int(parts[2]) << 8) | int(parts[3]))
	return addr;


func get_local_ip() -> String:
	return _local_ip


func get_public_ip() -> String:
	return _public_ip


func initiate_upnp_scan() -> bool:
	if _upnp_thread == null:
		_upnp_thread = Thread.new();
		_upnp_thread.start(_discovery_worker)
		return true

	return false


func add_upnp_mapping(port: int, proto := "UDP") -> bool:
	if _upnp_thread == null:
		_upnp_thread = Thread.new();
		_upnp_thread.start(_add_port_worker.bind(port, proto))
		return true

	return false


func remove_upnp_mapping(port: int, proto := "UDP") -> bool:
	if _upnp_thread == null:
		_upnp_thread = Thread.new();
		_upnp_thread.start(_remove_port_worker.bind(port, proto))
		return true

	return false


func set_capability_callback(callable: Callable) -> void:
	_client.set_capability_callback(callable)


func set_connection(conn) -> Error:
	var old = _wrapper

	if conn is StreamPeerTCP:
		_wrapper = BackendWrapper.TcpWrapper.new(conn)
		_wrapper.debug = debug
		_client.reset()
	elif conn is StreamPeerTLS:
		_wrapper = BackendWrapper.TlsWrapper.new(conn)
		_wrapper.debug = debug
		_client.reset()
	elif conn is WebSocketPeer:
		_wrapper = BackendWrapper.WebSocketWrapper.new(conn)
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


# send a fully formed IRC message
func send_raw(msg: String) -> void:
	_client.queue_message(msg)


# Sends a private message or a message to a channel
func send_message(target: String, message: String) -> void:
	_client.queue_message("PRIVMSG %s :%s\r\n" % [ target, message ])


# Sends a notice to a user or channel
func send_notice(target: String, message: String) -> void:
	_client.queue_message("NOTICE %s :%s\r\n" % [ target, message ])


# Changes the nick of the client
func change_nick(nick: String) -> void:
	_client.queue_message("NICK %s\r\n" % nick)


# Joins a channel
func join_channel(channel: String) -> void:
	_client.queue_message("JOIN %s\r\n" % channel)


# Leaves a channel
func part_channel(channel: String) -> void:
	_client.queue_message("PART %s\r\n" % channel)


# Quits the irc server
func quit_server(message: String) -> void:
	_client.queue_message("QUIT %s\r\n" % message)


# Changes the mode for a specific channel
func change_mode(channel: String, mode: String, nick: String) -> void:
	_client.queue_message("MODE %s %s %s\r\n" % [ channel, mode, nick ])


# Kicks a user from a channel with a message
func kick_user(channel: String, nick: String, msg = "") -> void:
	if msg.is_empty():
		_client.queue_message("KICK %s %s\r\n" % [ channel, nick ])
	else:
		_client.queue_message("KICK %s %s :%s\r\n" % [ channel, nick, msg ])


# Changes the topic of a channel
func change_topic(channel: String, topic: String) -> void:
	_client.queue_message("TOPIC %s :%s\r\n" % [ channel, topic ])


# Clear the topic of a channel
func get_topic(channel: String) -> void:
	_client.queue_message("TOPIC %s\r\n" % channel)


# Gets a list of names from the current channel
func list_names(channel: String) -> void:
	_client.queue_message("NAMES %s\r\n" % channel)


# Gets a list of channels in the server.
# Can take a param like ">3" (more than 3 users) or "T<60" (topic change in less than 60 min ago)
func list_channels(param: String = "") -> void:
	_client.queue_message("LIST %s\r\n" % param)


# Send a custom ctcp command private message
func ctcp_request(target: String, command: String) -> void:
	_client.queue_message("PRIVMSG %s :\u0001%s\u0001\r\n" % [ target, command ])


# Respond to a ctcp command
func ctcp_response(target: String, command: String) -> void:
	_client.queue_message("NOTICE %s :\u0001%s\u0001\r\n" % [ target, command ])


# /me action
func me(target: String, message: String) -> void:
	ctcp_request(target, "ACTION " + message)


# send a DCC request
func dcc(target: String, type: String, arg: String, host: String, port: int) -> void:
	ctcp_request(target, "DCC %s %s %s %d" % [ type, arg, _raw_ip_to_dcc_ip(host), port ])


func _on_error(err: String) -> void:
	conn_error.emit(err)


func _on_close() -> void:
	conn_closed.emit()


func _on_connect() -> void:
	conn_established.emit()


func _on_established() -> void:
	irc_established.emit()
