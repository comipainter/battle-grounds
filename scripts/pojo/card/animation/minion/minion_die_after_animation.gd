### 回合结束
extends MinionAnimation
class_name MinionDieAfterAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion

func play() -> void:
	pass

class YongRanHuoFeng extends MinionDieAfterAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_fighting():
			# 准备随从数据
			var data: MinionData = DataManager.get_all_minion_data().filter_by(
				MinionDataCollection.Filter.new().set_name("永燃火凤")
			).get_array().front()
			var _function: Callable = func(_card: Card):
				(_card as Minion).get_info().get_counter_info().create_count(
					minion.get_info().get_counter_info().get_count(),
					10,
					"container",
					minion.get_info().get_counter_info().get_count_function()
				)
				(_card as Minion).get_info().get_counter_info().add_count(1)
			# 根据目前的计时器决定概率
			for i in range(2 if minion.get_info().is_golden() else 1):
				if randi_range(1, 10) > minion.get_info().get_counter_info().get_count():
					CardUtils.create_hand_card(
						CardUtils.create_minion_info(data),
						minion.global_position,
						minion,
						_function
					)
					CardUtils.create_desk_card(
						CardUtils.create_minion_info(data),
						minion.global_position,
						minion,
						_function
				)

class HaiDaoWuLai extends MinionDieAfterAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_fighting():
			for i in range(2 if minion.get_info().is_golden() else 1):
				CardUtils.create_desk_card(
						CardUtils.create_minion_info(
							DataManager.get_all_minion_data().filter_by(
								MinionDataCollection.Filter.new().set_name(
									"空中海盗"
								)
							).get_array().front()
						),
						minion.global_position,
						minion,
						func(card: Card):
							GameManager.get_main_scene().get_fight_component().get_handle_component().attack(
								card,
								CardUtils.get_opponent_card_collection(card).get_minion_collection().get_behit_minion()
							)
				)
			
class HaiShangZouSiFan extends MinionDieAfterAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_fighting():
			for i in range(2 if minion.get_info().is_golden() else 1):
				CardUtils.create_hand_card(
					CardUtils.create_magic_info(
						DataManager.get_sellable_magic_data().filter_by(
							MagicDataCollection.Filter.new().set_name(
								"酒馆币"
							)
						).get_array().front()
					),
					minion.global_position,
					minion
				)

class KuSiKaGongBing extends MinionDieAfterAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_fighting():
			for i in range(2 if minion.get_info().is_golden() else 1):
				var collection: MagicDataCollection = DataManager.get_all_magic_data().filter_by(
					MagicDataCollection.Filter.new().set_suzao(true).set_level_range(
						1,
						DataManager.get_shop_info().get_level()
					)
				).pick_random_collection(2, true)
				CardUtils.create_hand_card(
					CardUtils.create_magic_info(
						collection.get_array().get(0)
					),
					minion.global_position,
					minion
				)
				CardUtils.create_hand_card(
					CardUtils.create_magic_info(
						collection.get_array().get(1)
					),
					minion.global_position,
					minion
				)

class XianYanDeQiShou extends MinionDieAfterAnimation:
	func play() -> void:
		for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
			MinionUtils.add_stats(
				minion,
				_minion,
				StatsUtils.mul_stats(
					Stats.new(2, 2) if minion.get_info().is_golden() else Stats.new(1, 1),
					DataManager.get_player_info().get_player_effect_collection().find_effect(
						Effect_UseMagic
					).get_value()/3 + 1
				)
			)
