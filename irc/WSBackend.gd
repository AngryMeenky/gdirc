extends Node
class_name WsBackend


var _client = WebSocketPeer.new()
var host_uri: String

signal closed()
signal comm_connected()
signal data_received(data: String)
signal error(err: String)


func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connection_closed.connect(_closed)
	_client.connection_error.connect(_closed)
	_client.connection_established.connect(_connected)
	_client.data_received.connect(_on_data)

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(host_uri)
	if err != OK:
		error.emit("WS Unable to connect")
		set_process(false)


func _closed(_was_clean = false):
	closed.emit()
	set_process(false)


func send(text: String):
	_client.get_peer(1).put_packet((text + "\r\n").to_utf8_buffer())


func _connected(_proto = ""):
	comm_connected.emit()


func _on_data():
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	data_received.emit(data)


func _process(_delta):
	_client.poll()
