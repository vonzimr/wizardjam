
extends Spatial
var tetris
func _ready():
	var tex = get_node("Viewport").get_render_target_texture()
#	get_node("128k/128_screen").get("material/0").set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	get_node("Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	set_process_input(true)
	tetris = get_node("Viewport/Tetris/Grid")

func _input(ev):
	if (ev.is_action_pressed("move_left")):
		tetris.move_left()
	elif (ev.is_action_pressed("move_right")):
		tetris.move_right()
	elif (ev.is_action_pressed("move_up")):
		tetris.move_up()
	elif (ev.is_action_pressed("move_down")):
		tetris.move_down()
	elif(ev.is_action_pressed("rotate")):
		tetris.piece_rotate()