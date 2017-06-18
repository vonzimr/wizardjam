extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var position = 0
var audio
func _ready():
	connect("body_enter", self, "_play_audio")
	connect("body_exit", self, "_stop_audio")
	audio = get_node("audio")
	
func _play_audio(body):
	print(position)
	if(body.is_in_group("player")):
		audio.play(position)
	
func _stop_audio(body):
	if(body.is_in_group("player")):
		position = audio.get_pos()
		audio.stop()