extends PlayerEffect
class_name Effect_RoundAddCoin 
func _init(_value: int = 0) -> void:
	self.effect_name = "下回合获得金币"
	self.value = _value
	self.sprite_path = "res://assets/image/minion/南海卖艺者.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		return
	elif self.effect_name == _effect.effect_name:
		value += _effect.value
		_delete(_effect)
func _on_round_started() -> void:
	DataManager.get_shop_info().add_coin(value)
	self.value = 0
	_delete(self)
func get_description() -> String:
	return effect_name + "： " + str(value) + "枚"
