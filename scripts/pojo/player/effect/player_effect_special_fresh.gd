extends PlayerEffect
class_name Effect_SpecialFresh
@export var function: Callable
func _init(_value: int = 0, _function: Callable = func():pass) -> void:
	self.effect_name = "特殊刷新"
	self.value = _value
	self.function = _function
	self.sprite_path = "res://assets/image/minion/刷新畸体.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		pass
func _on_freshed() -> void:
	self.value -= 1
	self.function.call()
	if self.value == 0:
		_delete(self)
func get_description() -> String:
	return effect_name + "（剩余次数： " + str(value) + "）"
