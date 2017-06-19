extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var position = 0
onready var audio
onready var attract_music 
onready var in_game_music
func _ready():
	connect("body_enter", self, "_play_audio")
	connect("body_exit", self, "_stop_audio")
	get_node("../Viewport/Tetris/Grid").connect("switch_music", self, "switch_music")
	# Called every time the node is added to the scene.
	# Initialization here
	attract_music = get_node("attract")
	in_game_music = get_node("audio")
	audio = attract_music

func switch_music(mode):
	position = 0
	audio.stop()
	print(mode)
	if mode == "attract":
		audio = attract_music
	else:
		audio = in_game_music
	audio.play(position)


func _play_audio(body):
	print("Trying to play audio")
	print(position)
	if(body.is_in_group("player")):
		print("Hello?")
		audio.play(position)
	
func _stop_audio(body):
	if(body.is_in_group("player")):
		position = audio.get_pos()
		audio.stop()