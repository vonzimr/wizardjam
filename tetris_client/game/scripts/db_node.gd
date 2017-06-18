extends Node2D

var db

func _ready():
	var Connection = preload("res://scripts/Game_Client.gd")
	db = Connection.new("http://localhost", 8080)
	
	#Shows room code
	print(db.get_room_url())
	
	var thread = Thread.new()
	thread.start(self, "get_blocks_from_database")

func get_blocks_from_database(d):
	while true:
		var blocks = db.get_blocks(10)
		for block in blocks:
			print(block)
			var shape = parse_shape(block['shape'])
			get_node("../Grid").add_web_block(shape, block['quote'], block['submitted_by'])
		OS.delay_msec(1000)


func parse_shape(shape):
	var count = 0
	var vec_array = []
	for i in range(-2, 2):
		for x in range(-2, 2):
			if  shape[count] == true:
				vec_array.push_front(Vector2(x, i))
			count += 1
	return vec_array
