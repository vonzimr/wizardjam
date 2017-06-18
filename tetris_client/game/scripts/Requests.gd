extends Node
var _header
var _agent = "User-Agent: Pirulo/1.0 (Godot)"
var _http
var _base_url
var _port
	
func json_to_dict(resp):
	var json = str('{"array":',  resp, '}')
	var dict = {}
	dict.parse_json(json)
	return(dict['array'])

func clear_headers():
	_header = []

func set_header(headers):
	_header = []
	for header in headers:
		_header.append(header)

func add_headers(headers):
	for header in headers:
		_header.append(header)

func _init(base_url, port):
	_base_url = base_url
	_port = port

func connect():
	_http = HTTPClient.new()
	_http.connect(_base_url, _port, false)
	##print("Connecting...")
	while _http.get_status() == HTTPClient.STATUS_CONNECTING or _http.get_status() == HTTPClient.STATUS_RESOLVING:
		_http.poll()
		OS.delay_msec(500)
	assert(_http.get_status() == HTTPClient.STATUS_CONNECTED)

func server_request(method, url, data = null, headers=null):
	clear_headers()
	connect()
	
	var response
	
	if(headers != null):
		add_headers(headers)

	if(data != null):
		var json_bin = data.to_json().to_utf8()
		var content_type = "Content-Type: application/json; charset=UTF-8"
		var content_length = "Content-Length: " + str(json_bin.size())
		
		add_headers([_agent, content_type, content_length])
		
		response = _http.request_raw(HTTPClient.METHOD_POST, url, _header, json_bin)
	else:
		add_headers([_agent])
		
		response = _http.request(method, url, _header)

	assert( response == OK ) # Make sure all is OK

	while (_http.get_status() == HTTPClient.STATUS_REQUESTING):
    # Keep polling until the request is going on
		_http.poll()
		#print("Requesting..")
		OS.delay_msec(500)

	assert(_http.get_status() == HTTPClient.STATUS_BODY or _http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.

	if (_http.has_response()):

		var rb = RawArray() # Array that will hold the data

		while(_http.get_status()==HTTPClient.STATUS_BODY):
        # While there is body left to be read
			_http.poll()
			var chunk = _http.read_response_body_chunk() # Get a chunk
			if (chunk.size()==0):
            # Got nothing, wait for buffers to fill a bit
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer
		return {"content": rb.get_string_from_ascii(), "headers": _http.get_response_headers_as_dictionary()}

func post(url, data = null, headers=null):
	return server_request(HTTPClient.METHOD_POST, url, data, headers)

func get(url, headers=null):
	return server_request(HTTPClient.METHOD_GET, url, null, headers)

func delete(url, headers=null):
	return server_request(HTTPClient.METHOD_DELETE, url, null, headers)