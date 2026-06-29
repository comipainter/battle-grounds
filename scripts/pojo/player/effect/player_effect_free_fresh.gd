extends PlayerEffect
class_name Effect_FreeFresh
func _init(_value: int = 0) -> void:
	self.effect_name = "免费刷新"
	self.value = _value
	self.sprite_path = "res://assets/image/minion/刷新畸体.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		DataManager.get_shop_info().set_fresh_cost(0)
	elif self.effect_name == _effect.effect_name:
		self.value += _effect.value
		_delete(_effect)
func _on_freshed() -> void:
	self.value -= 1
	if self.value == 0:
		DataManager.get_shop_info().set_fresh_cost(ShopConstant.get_fresh_cost())
		_delete(self)
func get_description() -> String:
	return effect_name + "（剩余次数： " + str(value) + "）"
