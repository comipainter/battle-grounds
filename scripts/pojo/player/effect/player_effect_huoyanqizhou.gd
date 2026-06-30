class_name Effect_HuoYanQiZhou extends PlayerEffect
func _init() -> void:
	self.effect_name = "火焰祈咒"
	self.value = 1
	self.sprite_path = "res://assets/image/minion/fudai/火焰祈咒.png"
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
	var minion: Minion = collection.sort_by_position().get_array().front()
	if is_instance_valid(minion):
		MinionUtils.add_stats_uncare_from(minion, Stats.new(
			minion.get_info().get_stats().get_attack(),
			0
		))
	_delete(self)
func get_description() -> String:
	return effect_name + "： 战斗开始时，使你的最左边的随从攻击力翻倍"
