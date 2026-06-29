class_name Effect_CaiFu extends PlayerEffect
func _init() -> void:
	self.effect_name = "在你下次花费铸币时，返还相同数量的铸币"
	self.value = 1
	self.sprite_path = "res://assets/image/magic/财富悬赏令.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		return
	elif self.effect_name == _effect.effect_name:
		self.value += _effect.value
		_delete(_effect)
func _on_coin_subed(subed_coin: int) -> void:
	DataManager.get_shop_info().add_coin(subed_coin)
	self.value -= 1
	if self.value == 0:
		_delete(self)
func get_description() -> String:
	return effect_name + "（剩余次数： " + str(value) + "）"
