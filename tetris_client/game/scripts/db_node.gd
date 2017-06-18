extends Node2D
signal poll_database
var db
var thread = Thread.new()
	# Called every time the node is added to the scene.
func _ready():
	var Connection = preload("res://scripts/Game_Client.gd")
	db = Connection.new("http://localhost", 8080)
	print(db.get_room_url())


func push_blocks_to_grid(userdata):
	var info = db.get_blocks(1);

	print(info)
	print(info.size())
	if(info == null):
		get_node("../Grid").block_shapes.push_front({"msg": "Hello", "shape": [Vector2(0, 1), Vector2(1,0)]})
		return []
	if(info.size() == 0):
		get_node("../Grid").block_shapes.push_front({"msg": "Hello", "shape": [Vector2(0, 1), Vector2(1,0)]})
	else:
		for i in range(info.size()):
			print("for loop")
			get_node("../Grid").add_block(parse_shape(info[i]['shape']), info[i]['quote'])
	thread = Thread.new()
	
func push_blocks_threaded():
	if not thread.is_active():
		thread.start(self, "push_blocks_to_grid")

func parse_shape(shape):
	var count = 0
	var vec_array = []
	for i in range(-2, 2):
		for x in range(-2, 2):
			if  shape[count] == true:
				vec_array.push_front(Vector2(x, i))
			count += 1
	return vec_array
