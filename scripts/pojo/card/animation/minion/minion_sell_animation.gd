### 出售
extends MinionAnimation
class_name MinionSellAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion
func play() -> void:
		pass
		
class ShangFanYuanSu extends MinionSellAnimation:
	func play() -> void:
		if is_instance_valid(GameManager.mainScene):
			for i in range(2 if minion.get_info().is_golden() else 1):
				var info: MinionInfo = CardUtils.create_minion_info(
						DataManager.get_sellable_minion_data().filter_by(
							MinionDataCollection.Filter.new().set_level_range(
								1, 
								DataManager.get_shop_info().get_level()
							).set_race(
								Race.Type.YuanSu
							)
						).pick_random()
					)
				info.set_stats(Stats.new(1, 1))
				CardUtils.create_hand_card(
					info,
					minion.global_position,
					minion
				)

class BaiZhuanDuTu extends MinionSellAnimation:
	func play() -> void:
		DataManager.get_shop_info().add_coin(4 if minion.get_info().is_golden() else 2)
		
class JinBiZhaPianFan extends MinionSellAnimation:
	func play() -> void:
		DataManager.get_shop_info().set_coin_limit(
			DataManager.get_shop_info().get_coin_limit() - minion.get_info().get_boost_counter_info().get_count()
		)

class LanKeShiZuGui extends MinionSellAnimation:
	func play() -> void:
		match DataManager.get_last_fight_phase().get_winner():
			"enemy":
				DataManager.get_shop_info().add_coin(
					8 if minion.get_info().is_golden() else 4
				)

class NaiXinDeZhenChaYuan extends MinionSellAnimation:
	func play() -> void:
		for j in range(2 if minion.get_info().is_golden() else 1):
			var choice_data_array: Array[MinionData] = []
			for i in range(3):
				choice_data_array.append(
					DataManager.get_sellable_minion_data().filter_by(
						MinionDataCollection.Filter.new().set_level(
							mini(
								minion.get_info().get_counter_info().get_count(),
								ShopConstant.get_max_level()
							)
						)
					).pick_random()
				)
			var faxianAnimation = PlayerAniamtion.FaXianChoose.new(choice_data_array)
			GameManager.get_main_scene().get_player_component().add_animation(
				faxianAnimation
			)
			var choosedIndex: int = await faxianAnimation.choice_made
			if choosedIndex != null:
				CardUtils.create_hand_card(
					CardUtils.create_minion_info(choice_data_array[choosedIndex]),
					minion.global_position,
					minion
				)
		super.play()
