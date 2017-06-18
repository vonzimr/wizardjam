extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var shape
var texture
var colors
var bs
var label
func init(pos):
	set_pos(pos)
	label = get_child(0)
	label.set_text("No Submission!")
	

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func preview_block(texture, shape, colors):
	self.shape = shape
	self.texture = texture
	self.colors = colors
	self.bs = texture.get_size()
	update()

func set_label(message):
	var label = get_child(0)
	label.set_text(message)
func _draw():
	var offset = Vector2(20, 20)
	if(shape != null && texture != null && colors != null && bs != null):
		for c in shape:
			draw_texture_rect(texture, Rect2((c)*bs + offset, bs), false, colors[0])