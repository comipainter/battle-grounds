class_name MinionEffect_HaiChaoDeZhuFu extends MinionEffect

func _init() -> void:
	self.effect_name = "直到下回合拥有亡语：召唤一只3/2的螃蟹"
	self.sprite_path = "res://assets/image/magic/海潮的祝福.png"
func get_description() -> String:
	return effect_name
func _on_round_started(minion: Minion) -> void:
	# 解除绑定
	_delete(self)
func _on_dead_after(minion: Minion) -> void:
	CardUtils.create_desk_card(
		CardUtils.create_minion_info(
			DataManager.get_all_minion_data().filter_by(
				MinionDataCollection.Filter.new().set_name(
					"螃蟹"
				)
			).get_array().front()
		),
		minion.global_position,
		minion
	)
