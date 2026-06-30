extends Sprite2D
class_name MagicViewportComponent

@onready var vp: SubViewport = $"../../MagicInfo/SubViewportContainer/SubViewport"

var magic: Magic
func set_magic(_magic: Magic):
	magic = _magic
	if magic.get_info().is_suzao():
		self.material.set_shader_parameter("enable_wave", true)
	
func _ready() -> void:
	self.texture = vp.get_texture()
	
