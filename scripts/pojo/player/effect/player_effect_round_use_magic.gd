class_name Effect_RoundUseMagic extends PlayerEffect
func _init() -> void:
	self.effect_name = "本回合释放法术"
	self.value = 0
	self.sprite_path = "res://assets/image/minion/肌肉领主滑矛.png"
func _on_used_magic(magic: Magic) -> void:
	self.value += 1
func _on_round_started() -> void:
	self.value = 0
