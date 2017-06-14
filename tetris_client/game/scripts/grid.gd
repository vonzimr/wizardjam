
extends Control

# Simple Tetris-like demo, (c) 2012 Juan Linietsky
# Implemented by using a regular Control and drawing on it during the _draw() callback.
# The drawing surface is updated only when changes happen (by calling update())

# Member variables
var score = 0
var score_label = null

const MAX_SHAPES = 7

var block = preload("res://images/block.png")

var block_colors = [
	Color(1, 0.5, 0.5),
	Color(0.5, 1, 0.5),
	Color(0.5, 0.5, 1),
	Color(0.8, 0.4, 0.8),
	Color(0.8, 0.8, 0.4),
	Color(0.4, 0.8, 0.8),
	Color(0.7, 0.7, 0.7)]

var block_shapes = [
	[ Vector2(0, -1), Vector2(0, 0)],
	[ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3) ], # I
	[ Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1) ], # O
	[ Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0) ], # S
	[ Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(-1, 0) ], # Z
	[ Vector2(-1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0) ], # L
	[ Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0) ], # J
	[ Vector2(0, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0) ], # T
]

var block_rotations = [
	Matrix32(Vector2(1, 0), Vector2(0, 1), Vector2()),
	Matrix32(Vector2(0, 1), Vector2(-1, 0), Vector2()),
	Matrix32(Vector2(-1, 0), Vector2(0, -1), Vector2()),
	Matrix32(Vector2(0, -1), Vector2(1, 0), Vector2())]

var width = 0
var height = 0

var cells = {}

var piece_active = false
var piece_shape #Individual block coordinates
var piece_pos = Vector2()
var piece_rot = 0

var preview_pos = Vector2()
var preview_rot = 0

func piece_cell_xform(p, er = 0):
	#p is a vector rom the block_list
	var r = (4 + er + piece_rot) % 4
	#Transforms for the piece based on the list of block rotations
	#r is used as the "rotation index" of the block rotations list
	return piece_pos + block_rotations[r].xform(p)


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
		for c in piece_shape:
			#block = texture
			draw_texture_rect(block, Rect2(piece_cell_xform(c)*bs, bs), false, block_colors[0])
	if(block_shapes.size() > 0):
		preview_block(get_node("../preview_1").get_global_pos() / 16, 0)
	if(block_shapes.size() > 1):
		preview_block(get_node("../preview_2").get_global_pos() / 16, 1)
	if(block_shapes.size() > 2):
		preview_block(get_node("../preview_3").get_global_pos() / 16, 2)

func preview_block(offset, index):
	var bs = block.get_size()
	for c in block_shapes[index]:
		draw_texture_rect(block, Rect2((c+offset)*bs, bs), false, block_colors[0])
		update()

func piece_check_fit(piece_shape, ofs, er = 0):
	for c in piece_shape:
		var pos = piece_cell_xform(c, er) + ofs
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
	piece_shape = block_shapes.front()
	block_shapes.pop_front()
	piece_pos = Vector2(width/2, 2)
	piece_active = true
	piece_rot = 0
	
	if (not piece_check_fit(piece_shape, Vector2(0, 1))):
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

func display_block():
	var test_shape = piece_shape
	var test_pos = piece_pos
	while(piece_check_fit(test_shape, Vector2(0, 1 ))):
		test_pos.y += 1
		update()

	
func fast_drop():
	while(piece_check_fit(piece_shape, Vector2(0, 1 ))):
		piece_pos.y += 1
		update()

func piece_move_down():
	if (!piece_active):
		return
	#Uses Vector2(0, 1) to make sure it can fit in the next row
	if (piece_check_fit(piece_shape, Vector2(0, 1))):
		piece_pos.y += 1
		update()
	else:
		for c in piece_shape:
			var pos = piece_cell_xform(c)
			cells[pos] = piece_shape
		test_collapse_rows()
		if(block_shapes.size() > 0):
			new_piece()
		#IF no shapes are available, make the current shape inactive!
		else:
			piece_active = false


func piece_rotate():
	var adv = 1
	if (not piece_check_fit(piece_shape, Vector2(), 1)):
		return
	piece_rot = (piece_rot + adv) % 4
	update()


func _input(ie):
	if(ie.is_action("new_block")):
		#For debugging!
		block_shapes.push_front([ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3) ])
		piece_active = true
	if (not piece_active):
		return
	if (!ie.is_pressed()):
		return

	if (ie.is_action("move_left")):
		if (piece_check_fit(piece_shape, Vector2(-1, 0))):
			piece_pos.x -= 1
			update()
	elif (ie.is_action("move_right")):
#		display_block()
		if (piece_check_fit(piece_shape, Vector2(1, 0))):
			piece_pos.x += 1
			update()
	elif (ie.is_action("move_up")):
		fast_drop()
	elif (ie.is_action("move_down")):
		if (piece_check_fit(piece_shape, Vector2(0, 1))):
			piece_pos.y += 1
			update()
	elif (ie.is_action("rotate")):
		piece_rotate()

func setup(w, h):
	width = w
	height = h
	set_size(Vector2(w, h)*block.get_size())
	new_piece()
	get_node("timer").start()


func _ready():
	piece_shape = block_shapes.front()
	piece_shape.pop_front()
	setup(20, 30)
	score_label = get_node("../score")
	
	set_process_input(true)
