extends RefCounted
class_name BackendWrapper

signal conn_closed()
signal conn_established()
signal conn_error(err: String)


@export var debug := false


func poll() -> void:
	pass


func get_status() -> IRC.Status:
	return IRC.Status.STATUS_DISCONNECTED


func get_available_packet_count() -> int:
	return 0


func get_packet() -> String:
	return ""


func get_packet_error() -> Error:
	return ERR_DOES_NOT_EXIST


func put_packet(packet: String) -> Error:
	return ERR_LINK_FAILED


class TcpWrapper:
	extends BackendWrapper

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


	func get_status() -> IRC.Status:
		return _tcp.get_status() as IRC.Status


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
			data.append_array(IRC.ENDL)
		return _tcp.put_data(data)


class TlsWrapper:
	extends BackendWrapper

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


	func get_status() -> IRC.Status:
		return _tls.get_status() as IRC.Status


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
			data.append_array(IRC.ENDL)
		return _tls.put_data(data)


class WebSocketWrapper:
	extends BackendWrapper

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


	func get_status() -> IRC.Status:
		match _ws.get_ready_state():
			WebSocketPeer.STATE_CONNECTING:
				return IRC.Status.STATUS_CONNECTING
			WebSocketPeer.STATE_OPEN:
				return IRC.Status.STATUS_CONNECTED
			WebSocketPeer.STATE_CLOSING:
				return IRC.Status.STATUS_CLOSING
			WebSocketPeer.STATE_CLOSED, _:
				return IRC.Status.STATUS_DISCONNECTED


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
