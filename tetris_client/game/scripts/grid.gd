
extends Control
signal move_con(input)
signal play_sample(samp_name)
signal switch_music(mode)
# Simple Tetris-like demo, (c) 2012 Juan Linietsky
# Implemented by using a regular Control and drawing on it during the _draw() callback.
# The drawing surface is updated only when changes happen (by calling update())

# Member variables
var score = 0
var score_label = null
var gameover_timer
const MAX_SHAPES = 7
var timer
var logo

#Difficulty Settings
var game_speed = 1
var next_level = 300
var level = 0


var gameover_label
var attract_label

#GAME STATES
var cur_state
enum STATE{
	ATTRACT,
	INGAME,
	GAMEOVER

}


func set_state(state):
	cur_state = state

func get_state(state):
	return cur_state


func attract_state():
	attract_label.show()
	gameover_label.hide()
	piece_active = false
	cells.clear()
	cur_state = ATTRACT
	timer.set_wait_time(.0125)
	timer.start()
	logo.show()
	emit_signal("switch_music", "attract")
	drop_random_piece()

func ingame_state():
	logo.hide()
	attract_label.hide()
	gameover_label.hide()
	timer.set_wait_time(game_speed)
	timer.start()
	score = 0
	score_label.set_text("0")
	cells.clear()
	emit_signal("switch_music", "in-game")
	get_parent().get_node("attract_label").hide()
	piece_active = true
	get_node("../restart").release_focus()
	update()
	cur_state = INGAME

	new_piece()

func game_over_state():
	attract_label.hide()
	logo.show()
	gameover_timer.start()
	gameover_label.show()
	cur_state = GAMEOVER
	piece_active = true
	emit_signal("play_sample", "death")
	emit_signal("switch_music", "attract")
	update()


var block = preload("res://images/block.png")
var previews = []
var block_colors = [
	Color(1, 0.5, 0.5),
	Color(0.5, .5, 0.5, .5),
	Color(0.5, 0.5, 1),
	Color(0.8, 0.4, 0.8),
	Color(0.8, 0.8, 0.4),
	Color(0.4, 0.8, 0.8),
	Color(0.7, 0.7, 0.7)]
	
var web_block_shapes = [
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"},
{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ], "submitted_by": "Paul"}
]

onready var block_shapes = [
	{"msg": "Wizard", "shape": [ Vector2(0, -1), Vector2(0, 0), Vector2(0, 1), Vector2(0, 2) ]},
	{"msg": "Make your friends submit blocks", "shape": [ Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1) ]},
	{"msg": "You got this block cuz ur lonely", "shape": [ Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0) ]},
	{"msg": "Boring blocks", "shape": [ Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(-1, 0) ]},
	{"msg": "There are only as many canned quotes as there are tetronimoes", "shape": [ Vector2(-1, 1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0) ]},
	{"msg": "Have you tried BLUM mode?", "shape": [ Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0) ]},
	{"msg": "Pssst... " + get_parent().get_node("db_node").db.get_room_code(), "shape": [ Vector2(0, 1), Vector2(1, 0), Vector2(0, 0), Vector2(-1, 0) ]}]


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
#	var sb = get_stylebox("bg", "Tree") # Use line edit bg
#	draw_style_box(sb, Rect2(Vector2(), get_size()).grow(3))
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
	

func drop_random_piece():
	randomize()
	piece_dic = block_shapes[floor(rand_range(0, block_shapes.size()))]
	randomize()
	piece_pos = Vector2(round(rand_range(1, width-2)), 2)
	piece_active = true
	piece_rot = 0
	if (not piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
		cells.clear()
	update()

func new_piece():
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
		game_over_state()
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
			emit_signal("play_sample", "line clear")
			accum_down += 1
	
	score += accum_down*100
	score_label.set_text(str(score))


func display_block(shape):
	var test_pos = Vector2(piece_pos.x, 0)
	while(piece_check_fit(shape, Vector2(0, test_pos.y+1 ))):
		test_pos.y += 1

	return test_pos

func fast_drop():
	if piece_active:
		emit_signal("play_sample", "drop")
		while(piece_check_fit(piece_dic["shape"], Vector2(0, 1 ))):
			piece_pos.y += 1
			update()
		piece_move_down()
			

func show_message(msg):
	var label = get_node("../diag_text/Label")
	label.set_dialog_text([msg])
	label.next_dialog()
	var speed = 1
	if piece_dic["msg"].length() != 0:
		speed = 1.000 / piece_dic["msg"].length()
	get_node("../diag_text/AnimationPlayer").play("fade", -1, speed + .2 )

	
	
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
		show_message(piece_dic["msg"])
		if(block_shapes.size() > 0):
			if cur_state == INGAME:
				new_piece()
			if cur_state == ATTRACT:
				drop_random_piece()
			#Check if new blocks were added to the database in a separate thread
		#IF no shapes are available, make the current shape inactive!
		else:
			piece_active = false

func piece_rotate():
	var adv = 1
	if (not piece_check_fit(piece_dic["shape"], Vector2(), 1)):
		return
	piece_rot = (piece_rot + adv) % 4
	emit_signal("play_sample", "rotate left")
	update()

func move_down():
	if (piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
		piece_pos.y += 1
		update()

func attract_input(ie):
	if (ie.is_action("reset")):
		cur_state = INGAME
		ingame_state()

func gameover_input(ie):
	if (ie.is_action("reset")):
		ingame_state()

func ingame_input(ie):
	if (ie.is_action("move_left") and ie.is_pressed()):
		if (piece_check_fit(piece_dic["shape"], Vector2(-1, 0))):
			piece_pos.x -= 1
			emit_signal("move_con", "stick_left")
			update()
	elif (ie.is_action("move_right") and ie.is_pressed()):
		if (piece_check_fit(piece_dic["shape"], Vector2(1, 0))):
			piece_pos.x += 1
			emit_signal("move_con", "stick_right")
			update()
	elif (ie.is_action_pressed("move_up")):
		emit_signal("move_con", "stick_up")
		fast_drop()
	elif (ie.is_action("move_down")  and ie.is_pressed()):
		emit_signal("move_con", "stick_down")
		if (piece_check_fit(piece_dic["shape"], Vector2(0, 1))):
			piece_pos.y += 1
			update()
	elif (ie.is_action_pressed("rotate")):
		emit_signal("move_con", "button")
		piece_rotate()	

func _input(ie):
	if cur_state == ATTRACT:
		attract_input(ie)
	elif cur_state == INGAME:
		ingame_input(ie)
	elif cur_state == GAMEOVER:
		gameover_input(ie)



func setup(w, h):
	width = w
	height = h
	set_size(Vector2(w, h)*block.get_size())
	attract_state()



func create_preview_windows():
	var p_nodes = get_parent().get_node("previews")
	var preview_scene = load("res://scenes/preview.tscn")
	for p in p_nodes.get_children():
		previews.append(p)


func _ready():
	gameover_timer = get_node("overtimer")
	timer = get_node("timer")
	logo = get_node("logo").get_node("Label")
	score_label = get_node("../score")
	gameover_label = get_parent().get_node("gameover_label")
	attract_label = get_parent().get_node("attract_label")
	create_preview_windows()
	cur_state = ATTRACT
	setup_game()
	set_process(true)



func setup_game():
	setup(20, 30)
	set_process_input(true)

func increase_level(score):
	var increase_level = next_level - score
	if increase_level < 0:
		next_level += 300
		level += 1
		game_speed += .1
		timer.set_wait_time(max(.05, 1 - game_speed))
		timer.start()
		get_parent().get_node("level_num").set_text(str(level))
	



func _process(delta):
	if(cur_state == GAMEOVER):
		level = 0
		gameover_label.show()
		var time = gameover_timer.get_time_left()
		gameover_label.set_text("Insert More Coins\n(Tap R More)\nTime Remaining: "  + str(floor(time)))
		if(time == 0):
			gameover_label.hide()
			attract_state()
	if(cur_state == INGAME):
		increase_level(score)

	