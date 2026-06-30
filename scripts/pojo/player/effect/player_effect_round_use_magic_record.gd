class_name Effect_RoundMagicRecord extends PlayerEffect
@export var info_array: Array[MagicInfo] = []
func _init() -> void:
	self.effect_name = "本回合释放过的法术"
	self.value = 0
	self.sprite_path = "res://assets/image/minion/风暴分流者.png"
func _on_used_magic(magic: Magic) -> void:
	info_array.append(magic.get_info())
func _on_round_started() -> void:
	info_array.clear()
func get_array() -> Array[MagicInfo]:
	return info_array
