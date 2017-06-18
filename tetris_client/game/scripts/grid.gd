
extends Control
signal move_con(input)
# Simple Tetris-like demo, (c) 2012 Juan Linietsky
# Implemented by using a regular Control and drawing on it during the _draw() callback.
# The drawing surface is updated only when changes happen (by calling update())

# Member variables
var score = 0
var score_label = null

const MAX_SHAPES = 7

var block = preload("res://images/block.png")
var previews = []
var block_colors = [
	Color(1, 0.5, 0.5),
	Color(0.5, 1, 0.5, .1),
	Color(0.5, 0.5, 1),
	Color(0.8, 0.4, 0.8),
	Color(0.8, 0.8, 0.4),
	Color(0.4, 0.8, 0.8),
	Color(0.7, 0.7, 0.7)]
var web_block_shapes = []

var block_shapes = [
	{"msg": "", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ]},
	{"msg": "", "shape": [ Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1) ]},
	{"msg": "", "shape": [ Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0) ]},
	{"msg": "", "shape": [ Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(-1, 0) ]},
	{"msg": "", "shape": [ Vector2(-1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0) ]},
	{"msg": "", "shape": [ Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0) ]},
	{"msg": "", "shape": [ Vector2(0, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0) ]}]


func add_web_block(block, msg, submitted_by):
	web_block_shapes.push_back({"msg": msg, "shape": block, "submitted_by": submitted_by})

func add_block(block, msg):
	block_shapes.push_front({"msg": msg, "shape": block})

var block_rotations = [
	Matrix32(Vector2(1, 0), Vector2(0, 1), Vector2()),
	Matrix32(Vector2(0, 1), Vector2(-1, 0), Vector2()),
	Matrix32(Vector2(-1, 0), Vector2(0, -1), Vector2()),
	Matrix32(Vector2(0, -1), Vector2(1, 0), Vector2())]

var width = 0
var height = 0

var cells = {}

var piece_active = false
var piece_dic = {'shape': null, 'message': null} #Individual block coordinates
var piece_pos = Vector2()
var piece_rot = 0

var test_pos = Vector2(piece_pos.x, piece_pos.y)

func piece_cell_xform(p, piece_pos, piece_rot, er = 0):
	#p is a vector rom the block_list
	var r = (4 + er + piece_rot) % 4
	#Transforms for the piece based on the list of block rotations
	#r is used as the "rotation index" of the block rotations list
	return piece_pos + block_rotations[r].xform(p)

func update_previews():
	if(web_block_shapes.size() > 0):
		for i in range(min(3, web_block_shapes.size())):
			previews[i].show()
			previews[i].preview_block(block, web_block_shapes[i]["shape"], block_colors)
			previews[i].set_label(web_block_shapes[i]["submitted_by"])
	
	if(web_block_shapes.size() < 3):
		for i in range(web_block_shapes.size(), 3):
			previews[i].hide()

func _draw():
	var sb = get_stylebox("bg", "Tree") # Use line edit bg
	draw_style_box(sb, Rect2(Vector2(), get_size()).grow(3))
#	draw_rect(Rect2(piece_pos.x*16, 0, 16, 500), block_colors[1] )
	var bs = block.get_size() #Used for multiplying the rect later on (size of image)
	for y in range(height):
		for x in range(width):
			if (Vector2(x, y) in cells):
				#block = texture
				draw_texture_rect(block, Rect2(Vector2(x, y)*bs, bs), false, block_colors[0])
	if (piece_active):
		for c in piece_dic["shape"]:
			#block = texture]
			#Draw one by one each square based on rotation and position on the screen.
			draw_texture_rect(block, Rect2(piece_cell_xform(c, piece_pos, piece_rot)*bs, bs), false, block_colors[0])
			#Drawing the preview block
			var max_pos = display_block(piece_dic["shape"])
			draw_texture_rect(block, Rect2(piece_cell_xform(c, Vector2(piece_pos.x, piece_pos.y + max_pos.y), piece_rot)*bs, bs), false, block_colors[1])
	update_previews()


func piece_check_fit(piece_dic, ofs, er = 0):
	for c in piece_dic:
		var pos = piece_cell_xform(c, piece_pos, piece_rot, er) + ofs
		if (pos.x < 0):
			return false
		if (pos.y < 0):
			return false
		if (pos.x >= width):
			return false
		if (pos.y >= height):
			return false
		#Cells are the current blocks currently put down
		if (pos in cells):
			return false
	
	return true

func new_piece():

	print(block_shapes.size())
	
	if web_block_shapes.size() == 0:
		randomize()
		piece_dic = block_shapes[floor(rand_range(0, block_shapes.size()))]
	else:
		piece_dic = web_block_shapes.front()
		web_block_shapes.pop_front()


	piece_pos = Vector2(width/2, 2)
	piece_active = true
	piece_rot = 0
	if (not piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
		# Game over
		game_over()
	
	update()

func test_collapse_rows():
	var accum_down = 0
	for i in range(height):
		var y = height - i - 1
		var collapse = true
		for x in range(width):
			if (Vector2(x, y) in cells):
				if (accum_down):
					#Move row above cleared row down.
					cells[Vector2(x, y + accum_down)] = cells[Vector2(x, y)]
			else:
				collapse = false
				if (accum_down):
					cells.erase(Vector2(x, y + accum_down))
		
		if (collapse):
			accum_down += 1
	
	score += accum_down*100
	score_label.set_text(str(score))

func game_over():
	piece_active = false
	get_node("gameover").set_text("Game over!")
	update()

func restart_pressed():
	score = 0
	score_label.set_text("0")
	cells.clear()
	get_node("gameover").set_text("")
	piece_active = true
	get_node("../restart").release_focus()
	update()

func display_block(shape):
	var test_pos = Vector2(piece_pos.x, 0)
	while(piece_check_fit(shape, Vector2(0, test_pos.y+1 ))):
		test_pos.y += 1

	return test_pos

func fast_drop():
	while(piece_check_fit(piece_dic["shape"], Vector2(0, 1 ))):
		piece_pos.y += 1
		update()

func show_message():
	var msg = get_node("../dialog_box")
	msg.get_node("diag_text/Label").set_dialog_text([piece_dic["msg"]])
	msg.get_node("diag_text/Label").next_dialog()
	msg.set_pos(Vector2(width/2, height/2)*16)
	msg.get_node("diag_text/AnimationPlayer").play("fade")
	
func piece_move_down():
	if (!piece_active):
		return
	#Uses Vector2(0, 1) to make sure it can fit in the next row
	if (piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
		piece_pos.y += 1
		update()
	else:
		for c in piece_dic["shape"]:
			var pos = piece_cell_xform(c, piece_pos, piece_rot)
			cells[pos] = piece_dic["shape"]
		test_collapse_rows()
		show_message()
		if(block_shapes.size() > 0):
			new_piece()
			#Check if new blocks were added to the database in a separate thread
		#IF no shapes are available, make the current shape inactive!
		else:
			piece_active = false

func piece_rotate():
	var adv = 1
	if (not piece_check_fit(piece_dic["shape"], Vector2(), 1)):
		return
	piece_rot = (piece_rot + adv) % 4
	update()

func move_down():
	if (piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
		piece_pos.y += 1
		update()

func _input(ie):
	if(ie.is_action("new_block")):
		#For debugging!
		block_shapes.push_front({"msg": "Nikoma has the football", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3) ]})
		piece_active = true
	if (not piece_active):
		return
	if (!ie.is_pressed()):
		return

	if (ie.is_action("move_left")):
		if (piece_check_fit(piece_dic["shape"], Vector2(-1, 0))):
			piece_pos.x -= 1
			emit_signal("move_con", "stick_left")
			update()
	elif (ie.is_action("move_right")):
		if (piece_check_fit(piece_dic["shape"], Vector2(1, 0))):
			piece_pos.x += 1
			emit_signal("move_con", "stick_right")
			update()
	elif (ie.is_action("move_up")):
		emit_signal("move_con", "stick_up")
		fast_drop()
	elif (ie.is_action("move_down")):
		emit_signal("move_con", "stick_down")
		if (piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
			piece_pos.y += 1
			update()
	elif (ie.is_action("rotate")):
		emit_signal("move_con", "button")
		piece_rotate()

func setup(w, h):
	width = w
	height = h
	set_size(Vector2(w, h)*block.get_size())
	new_piece()
	get_node("timer").start()




func _ready():
	score_label = get_node("../score")
	var preview_scene = load("res://scenes/preview.tscn")
	for i in range(3):
		var preview = preview_scene.instance()
		preview.init(Vector2(450, 150*i))
		previews.append(preview)
		add_child(preview)

func setup_game():
	setup(20, 30)
	set_process_input(true)
	

	
