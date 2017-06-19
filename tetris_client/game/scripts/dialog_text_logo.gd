extends Label


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_process(true)
	#timer.start()

var accum = 0
func _process(delta):
	accum += delta
	get_material().set_shader_param("Color", Vector3(sin(accum*2), cos(accum*5), tan(.2)))
	set_percent_visible(1)
	
#func _input(event):
#	if(event.is_action_pressed("INPUT_INTERACT") && timer.get_time_left() == 0):
#		set_text(dialogText[curDialog])
#		#print("%d: %s" %[curDialog, dialogText[curDialog]])
#		curDialog = (1 + curDialog) % dialogText.size()
#		timer.start()
