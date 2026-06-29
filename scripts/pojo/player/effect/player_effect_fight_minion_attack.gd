class_name Effect_FightMinionAttack extends PlayerEffect
func _init(_value: int = 0) -> void:
	self.effect_name = "本场战斗中的你随从额外拥有攻击力"
	self.value = _value
	self.sprite_path = "res://assets/image/minion/亡灵舰长伊丽扎.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		return
	elif self.effect_name == _effect.effect_name:
		value += _effect.value
		_delete(_effect)
func _on_round_started() -> void:
	_delete(self)
func _on_card_created(card: Card) -> void:
	if DataManager.get_game_info().is_fighting():
		if card.get_info().is_desk():
			if card.get_info().is_minion():
				(card as Minion).get_info().get_stats().add_stats(
					Stats.new(value, 0)
				)
