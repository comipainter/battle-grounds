class_name Effect_UseMagic extends PlayerEffect
func _init() -> void:
	self.effect_name = "本局释放法术"
	self.value = 0
	self.sprite_path = "res://assets/image/magic/奇术杂耍.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		pass
	elif self.effect_name == _effect.effect_name:
		self.value += _effect.value
		_delete(_effect)
func _on_used_magic(magic: Magic) -> void:
	self.value += 1
func get_description() -> String:
	return effect_name + "： " + str(value) + "次"
