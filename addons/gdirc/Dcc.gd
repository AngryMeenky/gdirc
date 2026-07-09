extends RefCounted
class_name IrcDcc


signal status_changed(status: State)
signal received_content(type: StringName)


const ACK  := &"ACK"
const DATA := &"DATA"
const CHAT := &"CHAT"


enum State {
	LISTENING,
	CONNECTING,
	SENDING,
	RECEIVING,
	CHATTING,
	COMPLETED,
	ERRORED,
	TERMINATED,
}


var _server: TCPServer = null
var _stream: StreamPeerTCP = null
var _data = null
var _counts := PackedInt32Array()
var _state := State.ERRORED
var _handler := Callable()
var _kind := ""
var _address := ""
var _port := 0
var _out: bool


func poll() -> Error:
	match _state:
		State.LISTENING:
			_stream = _server.take_connection()
			if _stream != null:
				_stream.big_endian = true
				_server.stop()
				_server = null
				_state = State.SENDING if _out else State.RECEIVING
				status_changed.emit(_state)

		State.CONNECTING:
			var status := _stream.get_status()
			if status == StreamPeerTCP.STATUS_CONNECTED:
				_state = State.SENDING if _out else State.RECEIVING
				status_changed.emit(_state)
			elif status == StreamPeerTCP.STATUS_ERROR:
				_state = State.ERRORED
				_stream.disconnect_from_host()
				_stream = null
				status_changed.emit(_state)

		State.SENDING, State.RECEIVING, State.CHATTING:
				return _handler.call() if _handler.is_valid() else ERR_METHOD_NOT_FOUND

		State.COMPLETED:
			return ERR_FILE_EOF

		_:
			return ERR_CONNECTION_ERROR

	return OK


func get_status() -> State:
	return _state


func get_ip() -> String:
	return _address


func get_port() -> int:
	return _port


func get_file_size() -> int:
	return _counts[0]


func get_transferred_bytes() -> int:
	return _counts[1]


func get_acknowledged_bytes() -> int:
	return _counts[2]


func get_byte_buffer() -> PackedByteArray:
	return _data if _data is PackedByteArray else PackedByteArray()


func get_available_lines() -> int:
	return _data[1].size() if _data is Array and _data.size() == 3 else 0


func get_line() -> String:
	if _data is Array and _data.size() == 3:
		var queue: PackedStringArray = _data[1]
		if not queue.is_empty():
			var line := queue[0]
			queue.remove_at(0)
			return line
	return ""


func put_line(text: String) -> void:
	if not (text.ends_with("\n") or text.ends_with("\r")):
		text += "\r\n"
	put_text(text)


func put_text(text: String) -> void:
	if _state == State.CHATTING:
		_data[2].append(text)


func terminate() -> void:
	match _state:
		State.LISTENING:
			_server.stop()
			_server = null
			_state = State.TERMINATED
			status_changed.emit(_state)


		State.CONNECTING, State.SENDING, State.RECEIVING, State.CHATTING:
			_stream.disconnect_from_host()
			_stream = null
			_state = State.TERMINATED
			status_changed.emit(_state)


# reverse: true->connect to addr:port, false->listen on addr:port
static func serve_file(path: String, addr: String, port: int, reverse := false) -> IrcDcc:
	var dcc := IrcDcc.new("FILE", addr, port, true)
	var fp := FileAccess.open(path, FileAccess.READ)
	if fp == null:
		printerr("Unable to open %s for reading: %s" % [ path, error_string(FileAccess.get_open_error()) ])
		dcc._state = State.ERRORED
	else:
		dcc._data = fp
		dcc._counts.append(fp.get_length())
		dcc._counts.append(0)
		dcc._counts.append(0)

	dcc._initialize_comm(reverse)

	if dcc._state == State.ERRORED:
		dcc._data = null
		fp.close()
	else:
		dcc._handler = dcc._serve_file_handler

	return dcc


# reverse: true->connect to addr:port, false->listen on addr:port
static func serve_buffer(bytes: PackedByteArray, addr: String, port: int, reverse := false) -> IrcDcc:
	var dcc := IrcDcc.new("BYTES", addr, port, true)
	dcc._data = bytes

	dcc._initialize_comm(reverse)

	if dcc._state == State.ERRORED:
		dcc._data = null
	else:
		dcc._handler = dcc._serve_buffer_handler
		dcc._counts.append(bytes.size())
		dcc._counts.append(0)
		dcc._counts.append(0)

	return dcc


static func receive_file(path: String, addr: String, port: int, expected := 0, reverse := false) -> IrcDcc:
	var dcc := IrcDcc.new("FILE", addr, port, false)
	var fp := FileAccess.open(path, FileAccess.WRITE)
	if fp == null:
		printerr("Unable to open %s for writing: %s" % [ path, error_string(FileAccess.get_open_error()) ])
		dcc._state = State.ERRORED

	dcc._initialize_comm(not reverse)

	if dcc._state == State.ERRORED:
		dcc._data = null
	else:
		dcc._handler = dcc._receive_file_handler
		dcc._counts.append(expected)
		dcc._counts.append(0)
		dcc._counts.append(0)

	return dcc


static func receive_buffer(addr: String, port: int, expected := 0, reverse := false) -> IrcDcc:
	var dcc := IrcDcc.new("BYTES", addr, port, false)

	dcc._initialize_comm(not reverse)

	if dcc._state != State.ERRORED:
		dcc._data = PackedByteArray()
	else:
		dcc._handler = dcc._receive_buff_handler
		dcc._counts.append(expected)
		dcc._counts.append(0)
		dcc._counts.append(0)

	return dcc


static func join_chat(addr: String, port: int, reverse := false) -> IrcDcc:
	var dcc := IrcDcc.new("CHAT", addr, port, reverse)

	dcc._initialize_comm(not reverse)

	if dcc._state != State.ERRORED:
		dcc._data = [ PackedByteArray(), PackedStringArray(), PackedStringArray() ]
		dcc._data[0].resize(16384)
		dcc._handler = dcc._chat_handler
		dcc._counts.append(dcc._data.size())
		dcc._counts.append(0)
		dcc._counts.append(0)

	return dcc


func _init(kind: String, addr: String, port: int, sending: bool):
	_kind = kind
	_address = addr
	_port = port
	_out = sending


func _initialize_comm(out: bool) -> Error:
	var err := OK

	if out:
		_stream = StreamPeerTCP.new()
		err = _stream.connect_to_host(_address, _port)
		if err != OK:
			printerr("Unable to connect to %s/%d: %s" % [ _address, _port, error_string(err) ])
			_state = State.ERRORED
			_stream = null
		else:
			_state = State.CONNECTING
	else:
		_server = TCPServer.new()
		err = _server.listen(_port, _address)
		if err != OK:
			printerr("Unable to listen on %s/%d: %s" % [ _address, _port, error_string(err) ])
			_state = State.ERRORED
			_server = null
		else:
			_state = State.LISTENING

	return err


func _serve_file_handler() -> Error:
	if _state == State.SENDING:
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_stream.disconnect_from_host()
			_state = State.ERRORED
			_stream = null
			_data.close()
			status_changed.emit(_state)
			return ERR_CONNECTION_ERROR

		var count := _counts[0]
		var sent := _counts[1]
		var acked := _counts[2]

		while _stream.get_available_bytes() >= 4:
			acked += _stream.get_32()

		if acked != _counts[2]:
			if acked >= count:
				_stream.disconnect_from_host()
				_state = State.COMPLETED
				_stream = null
				_data.close()
				status_changed.emit(_state)
				return ERR_FILE_EOF

			if sent == acked:
				var block := mini(8192, count - sent)
				var chunk: PackedByteArray = _data.get_buffer(block)
				if chunk.is_empty() or _stream.put_data(chunk) != OK:
					_stream.disconnect_from_host()
					_state = State.ERRORED
					_stream = null
					_data.close()
					return ERR_CONNECTION_ERROR
				sent += chunk.size()

			_counts[1] = sent
			_counts[2] = acked
			received_content.emit(ACK)

		return OK
	elif _state == State.COMPLETED:
		return ERR_FILE_EOF

	return ERR_CONNECTION_ERROR


func _serve_buffer_handler() -> Error:
	if _state == State.SENDING:
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_stream.disconnect_from_host()
			_state = State.ERRORED
			_stream = null
			status_changed.emit(_state)
			return ERR_CONNECTION_ERROR

		var count := _counts[0]
		var sent := _counts[1]
		var acked := _counts[2]

		while _stream.get_available_bytes() >= 4:
			acked += _stream.get_32()

		if acked != _counts[2]:
			if acked >= count:
				_stream.disconnect_from_host()
				_state = State.COMPLETED
				_stream = null
				status_changed.emit(_state)
				return ERR_FILE_EOF

			if sent == acked:
				var block := mini(8192, count - sent)
				if _stream.put_data(_data.slice(acked, acked + block)) != OK:
					_stream.disconnect_from_host()
					_state = State.ERRORED
					status_changed.emit(_state)
					_stream = null
					return ERR_CONNECTION_ERROR

			_counts[1] = sent
			_counts[2] = acked
			received_content.emit(ACK)

		return OK
	elif _state == State.COMPLETED:
		return ERR_FILE_EOF

	return ERR_CONNECTION_ERROR


func _receive_file_handler() -> Error:
	if _state == State.RECEIVING:
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_stream.disconnect_from_host()
			_state = State.ERRORED
			_stream = null
			_data.close()
			status_changed.emit(_state)
			return ERR_CONNECTION_ERROR

		var count := _counts[0]
		var received := _counts[1]
		var acked := _counts[2]
		var avail := _stream.get_available_bytes()

		if avail > 0:
			var res := _stream.get_data(avail)
			if res[0] != OK:
				_stream.disconnect_from_host()
				_state = State.ERRORED
				_stream = null
				status_changed.emit(_state)
				return ERR_CONNECTION_ERROR
			_data.store_buffer(res[1])
			received += res[1].size()
			_stream.put_32(received)
			acked = received
			_counts[1] = received
			_counts[2] = acked
			received_content.emit(DATA)

			if count > 0 and acked >= count:
				_stream.disconnect_from_host()
				_state = State.COMPLETED
				_stream = null
				_data.close()
				status_changed.emit(_state)
				return ERR_FILE_EOF

		return OK
	elif _state == State.COMPLETED:
		return ERR_FILE_EOF

	return ERR_CONNECTION_ERROR


func _receive_buffer_handler() -> Error:
	if _state == State.RECEIVING:
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_stream.disconnect_from_host()
			_state = State.ERRORED
			_stream = null
			status_changed.emit(_state)
			return ERR_CONNECTION_ERROR

		var count := _counts[0]
		var received := _counts[1]
		var acked := _counts[2]
		var avail := _stream.get_available_bytes()

		if avail > 0:
			var res := _stream.get_data(avail)
			if res[0] != OK:
				_stream.disconnect_from_host()
				_state = State.ERRORED
				_stream = null
				status_changed.emit(_state)
				return ERR_CONNECTION_ERROR
			_data.append_array(res[1])
			received += res[1].size()
			_stream.put_32(received)
			acked = received
			_counts[1] = received
			_counts[2] = acked
			received_content.emit(DATA)

			if count > 0 and acked >= count:
				_stream.disconnect_from_host()
				_state = State.COMPLETED
				_stream = null
				status_changed.emit(_state)
				return ERR_FILE_EOF

		return OK
	elif _state == State.COMPLETED:
		return ERR_FILE_EOF

	return ERR_CONNECTION_ERROR


func _chat_handler() -> Error:
	if _state == State.CHATTING:
		if _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			_stream.disconnect_from_host()
			_state = State.ERRORED
			status_changed.emit(_state)
			_stream = null
			return ERR_CONNECTION_ERROR

		# handle output
		var lines: PackedStringArray = _data[2]
		if not lines.is_empty():
			for line in lines:
				var bytes := line.to_utf8_buffer()
				_stream.put_data(bytes)
				_counts[1] += bytes.size()
			lines.clear()

		# handle input
		var avail := _stream.get_available_bytes()
		if avail > 0:
			var res := _stream.get_data(avail)
			if res[0] != OK:
				_stream.disconnect_from_host()
				_state = State.ERRORED
				_stream = null
				status_changed.emit(_state)
				return ERR_CONNECTION_ERROR
			var bytes: PackedByteArray = res[1]
			var buffer: PackedByteArray = _data[0]
			var queue: PackedStringArray = _data[1]
			buffer.append_array(bytes)
			_counts[2] += bytes.size()

			var cr: int = _data.find(0x0D)
			var lf: int = _data.find(0x0A)
			var idx: int = 0
			while idx < buffer.size() and (cr >= 0 or lf >= 0):
				cr = _data.find(0x0D, idx)
				lf = _data.find(0x0A, idx)

				if cr >= 0:
					if lf >= 0:
						if lf == cr + 1:
							queue.append(buffer.slice(idx, cr).get_string_from_utf8())
						elif lf == cr - 1:
							queue.append(buffer.slice(idx, lf).get_string_from_utf8())
						elif cr < lf:
							queue.append(buffer.slice(idx, cr).get_string_from_utf8())
							queue.append(buffer.slice(cr + 1, lf).get_string_from_utf8())
						else:
							queue.append(buffer.slice(idx, lf).get_string_from_utf8())
							queue.append(buffer.slice(lf + 1, cr).get_string_from_utf8())
						idx = maxi(cr, lf) + 1
					else:
						queue.append(buffer.slice(idx, cr).get_string_from_utf8())
						idx = cr + 1
				elif lf >= 0:
					queue.append(buffer.slice(idx, lf).get_string_from_utf8())
					idx = lf + 1

			if idx > 0:
				if idx < buffer.size():
					var slice := buffer.slice(idx)
					buffer.clear()
					buffer.append_array(slice)
				else:
					buffer.clear()
				received_content.emit(CHAT)

	return OK

func _to_string() -> String:
	return "DCC(%s): %s/%d" % [ _kind, _address, _port ]
