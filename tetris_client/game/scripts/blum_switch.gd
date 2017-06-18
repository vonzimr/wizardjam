extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	connect("body_enter", self, "toggle_bloom")
	connect("body_exit", self, "exit_bloom")

func toggle_bloom(body):
	set_process_input(true)
	get_node("../Control/diag_text").show()

func exit_bloom(body):
	get_node("../Control/diag_text").hide()
	get_parent().toggle_bloom()
	

func _input(event):
	if(event.is_action_pressed("blum")):
		get_parent().toggle_bloom()
