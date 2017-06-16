
extends Spatial
var tetris
var prev_pos = null


func _ready():
	var tex = get_node("Viewport").get_render_target_texture()
#	get_node("128k/128_screen").get("material/0").set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	get_node("Area/Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	set_process_input(true)
	tetris = get_node("Viewport/Tetris/Grid")
	get_node("Area").connect("input_event", self, "_on_area_input_event")

func _on_area_input_event(camera, event, click_pos, click_normal, shape_idx):
	print("hello")
	# Use click pos (click in 3d space, convert to area space)
	var pos = get_node("Area").get_global_transform().affine_inverse()*click_pos
	print(pos)
	# Convert to 2D
	pos = Vector2(pos.x, pos.y)
	# Convert to viewport coordinate system
	pos.x = (pos.x + .5)*800
	pos.y = (-pos.y + .5)*800
	# Set to event
	event.pos = pos
	event.global_pos = pos
	if (prev_pos == null):
		prev_pos = pos
	if (event.type == InputEvent.MOUSE_MOTION):
		event.relative_pos = pos - prev_pos
	prev_pos = pos
	# Send the event to the viewport
	get_node("Viewport/Tetris/Sprite").set_global_pos(pos)
	
	get_node("Viewport").input(event)


func _input(ev):
	# All other (non-mouse) events
	if (not ev.type in [InputEvent.MOUSE_BUTTON, InputEvent.MOUSE_MOTION, InputEvent.SCREEN_DRAG, InputEvent.SCREEN_TOUCH]):
		get_node("Viewport").input(ev)