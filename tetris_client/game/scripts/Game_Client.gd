extends "res://scripts/Requests.gd"
var token
var room_url

func _init(url, port).(url, port):
	var resp = .post("/api/room/create")
	var content = .json_to_dict(resp['content'])
	var headers = resp['headers']
	
	token = content['token']
	room_url = headers['Location']
	

func get_blocks(n):
	var header = ["x-access-token: " + token]
	var resp = .delete(room_url + "/submissions/" + String(n), header)
	return .json_to_dict(resp['content'])

func get_room_url():
	return _base_url + room_url