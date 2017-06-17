#https://www.reddit.com/r/godot/comments/4f5fkv/returning_json_files_using_httpclient/
extends Node
var HEADERS
var http
export var DEFAULT_BASE_URL = "http://127.0.0.1"
export var DEFAULT_PORT = 8080;
var access_json = {}
var access_token

func connectToServer(url=DEFAULT_BASE_URL):
	http = HTTPClient.new()
	var resp = http.connect(url, DEFAULT_PORT, false)
	##print("Connecting...")
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(500)
	assert(http.get_status() == HTTPClient.STATUS_CONNECTED)


func server_get(url, headers=null):
	if headers == null:
#		var auth = "Authorization: Bearer %s" % access_token
		var agent = "User-Agent: Pirulo/1.0 (Godot)"
		var accept = "Accept: */*"
		headers = [agent, accept]
	var err = http.request(HTTPClient.METHOD_GET, url, headers)

	assert( err == OK ) # Make sure all is OK

	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
    # Keep polling until the request is going on
		http.poll()
		#print("Requesting..")
		OS.delay_msec(500)


	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.

	if (http.has_response()):

		var rb = RawArray() # Array that will hold the data

		while(http.get_status()==HTTPClient.STATUS_BODY):
        # While there is body left to be read
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if (chunk.size()==0):
            # Got nothing, wait for buffers to fill a bit
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer
		return rb.get_string_from_ascii()
		
func server_delete(url, headers=null):
	if headers == null:
#		var auth = "Authorization: Bearer %s" % access_token
		var agent = "User-Agent: Pirulo/1.0 (Godot)"
		var accept = "Accept: */*"
		headers = [agent, accept]
	var err = http.request(HTTPClient.METHOD_DELETE, url, headers)

	assert( err == OK ) # Make sure all is OK

	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
    # Keep polling until the request is going on
		http.poll()
		#print("Requesting..")
		OS.delay_msec(500)


	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.

	if (http.has_response()):

		var rb = RawArray() # Array that will hold the data

		while(http.get_status()==HTTPClient.STATUS_BODY):
        # While there is body left to be read
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if (chunk.size()==0):
            # Got nothing, wait for buffers to fill a bit
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer
		return rb.get_string_from_ascii()


func server_post(url, data):
	var json_bin = data.to_json().to_utf8()
	var headers = ["Content-Type: application/json; charset=UTF-8", "Content-Length: " + str(json_bin.size())]
	var response = http.request_raw(HTTPClient.METHOD_POST, url, headers, json_bin)
	# Keep polling until the request is going on
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		OS.delay_msec(300)
	# Make sure request finished
	#print(http.get_status())
	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED)
	
	#print("Processing HTTP response")
	# Set up some variables
	var rb = RawArray()
	var chunk = 0
	var result = 0
	# Was there a response?
	#print("Response received?: "+str(http.has_response()))
	# Raw data array
	if http.has_response():
		
		# Get response headers
		var headers = http.get_response_headers_as_dictionary()
		##print("Response code: ", http.get_response_code())
		while(http.get_status() == HTTPClient.STATUS_BODY):
			http.poll()
			chunk = http.read_response_body_chunk()
			if(chunk.size() == 0):
				OS.delay_usec(100)
			else:
				rb = rb + chunk
			result = rb.get_string_from_ascii()
			#print(result.to_ascii().get_string_from_ascii())
		return [result, headers]
	else:
		print("error")
		return null
			

func create_room():
	var resp = server_post("/api/room/create", {})
	return resp[1]['Location']

func get_blocks(room_code, count):
	var resp = server_delete("/api/room/id/%s/submissions/%s" % [room_code, count])
	var json = str('{"array":',  resp, '}')
	var dict = {}
	dict.parse_json(json)
	print(resp)
	return dict
