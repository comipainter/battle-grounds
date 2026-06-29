class_name MinionEffect_KeJiYuanSuTi extends MinionEffect

func _init() -> void:
	self.effect_name = "已吸附：科技元素体"
	self.sprite_path = "res://assets/image/minion/科技元素体.png"
func is_xifu_effect() -> bool:
	return true
func get_description() -> String:
	return effect_name
