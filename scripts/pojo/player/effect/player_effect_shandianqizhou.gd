class_name Effect_ShanDianQiZhou extends PlayerEffect
func _init() -> void:
	self.effect_name = "闪电祈咒"
	self.value = 1
	self.sprite_path = "res://assets/image/minion/fudai/闪电祈咒.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		return
	elif self.effect_name == _effect.effect_name:
		_delete(_effect)
func _on_fight_started(side: String) -> void:
	var collection: MinionCollection
	match side: 
		"player":
			collection = CardUtils.get_fighting_enemy_desk_card_collection().get_minion_collection()
		"enemy":
			collection = CardUtils.get_fighting_player_desk_card_collection().get_minion_collection()
	if collection.size() != 0:
		for _minion in collection.pick_random_collection(
			mini(collection.size(), 3),
			false
		).get_array():
			_minion.get_info().take_damage(3)
	_delete(self)
func get_description() -> String:
	return effect_name + "： 战斗开始时，对3个随机敌方随从造成3伤害"
