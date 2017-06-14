extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	#Connects to the server, keeps connection alive.
	requests.connectToServer();
	#Gets array of all blocks.
	var info = requests.get_blocks();
	#All blocks
	print("All blocks.");
	print(info)
	#Accessing dict to get piece array
	print(info[0]['piece_array'])