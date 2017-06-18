extends Spatial
var tetris
var prev_pos = null
var anim
var world
func _ready():
	var tex = get_node("Viewport").get_render_target_texture()
	world = get_node("WorldEnvironment").get_environment()
	get_node("Area/Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	set_process_input(true)
	tetris = get_node("Viewport/Tetris/Grid")
	anim = get_node("arcade/AnimationPlayer")
	get_node("Area").connect("input_event", self, "_on_area_input_event")
	get_node("Viewport/Tetris/Grid").connect("move_con", self, "_move_con")
	get_node("arcade/blum_button/col").connect("input_event", self, "_switch_bloom")
	
func _switch_bloom(camera, event, click_pos, click_normal, shape_idx):
	
	if event.is_action_pressed("click"):
		if(world.is_fx_enabled(world.FX_GLOW)):
			get_node("blum").stop()
			world.set_enable_fx(world.FX_GLOW, false)
		else:
			get_node("blum").play()
			world.set_enable_fx(world.FX_GLOW, true)
		
	

func _move_con(input):
	print("Hello")
	print(anim.get_current_animation())
	anim.play(input)

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
