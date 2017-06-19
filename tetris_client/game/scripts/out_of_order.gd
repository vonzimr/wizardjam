extends Quad

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func _ready():
	var tex = get_node("../out_of_order").get_render_target_texture()
	get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)