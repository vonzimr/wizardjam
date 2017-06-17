extends Node2D
signal poll_database
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var thread = Thread.new()
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	#Connects to the server, keeps connection alive.
	requests.connectToServer();
	#Gets array of all blocks.
	#All blocks
	#Accessing dict to get piece array
	#push_blocks_to_grid(null)
	var room_location = requests.create_room()
	var blocks = requests.get_blocks("FKEUQ4QXY", 5)
	print(blocks)
	print("room loc: " + room_location)
	#get_node("../Grid").setup_game()
	#connect("poll_database", self, "push_blocks_to_grid")

func push_blocks_to_grid(userdata):
	var info = requests.get_blocks('AAA', 5);
	for i in range(info.size()):
		get_node("../Grid").add_block(parse_piece_array(info[i]['piece_array']), info[i]['quote'])
	thread = Thread.new()
	
func push_blocks_threaded():
	if not thread.is_active():
		thread.start(self, "push_blocks_to_grid")

func parse_piece_array(piece_array):
	var count = 0
	var vec_array = []
	for i in range(-2, 2):
		for x in range(-2, 2):
			if piece_array[count] == true:
				vec_array.push_front(Vector2(x, i))
			count += 1
	return vec_array
