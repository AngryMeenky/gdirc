extends Node
class_name TcpsBackend


var host_uri: String

signal closed()
signal comm_connected()
signal data_received(data: String)
signal error(err: String)

var _status: int = 0
var _stream: StreamPeerTLS = StreamPeerTLS.new()


func _ready() -> void:
	_status = _stream.get_status()


func _process(_delta: float) -> void:
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_DISCONNECTED:
				closed.emit()
			_stream.STATUS_CONNECTED:
				comm_connected.emit()
			_stream.STATUS_ERROR:
				error.emit("TCP + SSL connection error")

			_stream.STATUS_HANDSHAKING:
				print("Performing SSL handshake with host.")
			_stream.STATUS_ERROR_HOSTNAME_MISMATCH:
				error.emit("Error with socket stream: Hostname mismatch.")

	if _status == _stream.STATUS_CONNECTED:
		_stream.poll()
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = _stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				error.emit("TCP Error getting data from stream: " + str(data[0]))
			else:
				data_received.emit(data[1].get_string_from_utf8())


func connect_to_host(host: String, port: int) -> void:
	print("TCP + SSL Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_DISCONNECTED
	var tcp: StreamPeerTCP = StreamPeerTCP.new()
	var err: int = tcp.connect_to_host(host, port)
	if err != OK:
		error.emit("TCP + SSL Error connecting to host: " + str(err))
		return
	err = _stream.connect_to_stream(tcp, "IRC", TLSOptions.client_unsafe())
	if err != OK:
		error.emit("TCP + SSL Error upgrading connection to SSL: " + str(err))


func send(data: String) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		error.emit("TCP Error: Stream is not currently connected.")
		return false
	var err: int = _stream.put_data((data + "\r\n").to_utf8_buffer())
	if err != OK:
		error.emit("TCP Error: " + str(err))
		return false
	return true
