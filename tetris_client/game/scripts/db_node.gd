extends Node2D
signal poll_database
var room
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var thread = Thread.new()
	# Called every time the node is added to the scene.
func _ready():
	# Initialization here
	
	#Connects to the server, keeps connection alive.
	#Gets array of all blocks.
	#All blocks
	#Accessing dict to get piece array
	#push_blocks_to_grid(null)
	room = requests.create_room()
	
	var blocks = requests.get_blocks(room['location'], 5, room['token'])
	print(blocks)
	print(room['location'])
	get_node("../Grid").setup_game()


func push_blocks_to_grid(userdata):
	var info = requests.get_blocks(room['location'], 5, room['token']);
	print(info)
	for i in range(info.size()):
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
