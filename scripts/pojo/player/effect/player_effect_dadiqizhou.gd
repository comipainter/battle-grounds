class_name Effect_DaDiQiZhou extends PlayerEffect
func _init() -> void:
	self.effect_name = "大地祈咒"
	self.value = 1
	self.sprite_path = "res://assets/image/minion/fudai/大地祈咒.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		return
	elif self.effect_name == _effect.effect_name:
		_delete(_effect)
func _on_fight_started(side: String) -> void:
	var collection: MinionCollection
	match side: 
		"player":
			collection = CardUtils.get_fighting_player_desk_card_collection().get_minion_collection()
		"enemy":
			collection = CardUtils.get_fighting_enemy_desk_card_collection().get_minion_collection()
	for minion in collection.get_array():
		minion.get_info().get_effect_collection().add_minion_effect(
			MinionEffect_DaDiQiZhou.new()
		)
	_delete(self)
func get_description() -> String:
	return effect_name + "： 战斗开始时，使你的随从获得亡语：召唤一个1/1的石元素"
