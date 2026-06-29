class_name MinionEffect_DaDiQiZhou extends MinionEffect

func _init() -> void:
	self.effect_name = "亡语：召唤一个1/1的石元素"
	self.sprite_path = "res://assets/image/minion/fudai/大地祈咒.png"
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
					"石元素"
				)
			).get_array().front()
		),
		minion.global_position,
		minion
	)
