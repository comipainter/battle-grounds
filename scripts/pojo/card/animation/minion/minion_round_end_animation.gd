### 回合结束
extends MinionAnimation
class_name MinionRoundEndAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion
func play() -> void:
		pass

class FuRaoDeJiYan extends MinionRoundEndAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			for i in range(2 if minion.get_info().is_golden() else 1):
				CardUtils.create_hand_card(
					CardUtils.create_minion_info(
						DataManager.get_sellable_minion_data().filter_by(
							MinionDataCollection.Filter.new().set_level_range(
								1, 
								DataManager.get_shop_info().get_level()
							).set_race(
								Race.Type.YuanSu
							).set_except_name(
								"富饶的基岩"
							)
						).pick_random()
					),
					minion.global_position,
					minion
				)

class YiLiuRongYan extends MinionRoundEndAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			var effect: Effect_RoundUseYuanSu = CardUtils.get_belong_player_effect(minion).find_effect(
				Effect_RoundUseYuanSu
			)
			if effect == null:
				push_error("no RoundYuanSu player effect find")
				return 
			for i in range(2 if minion.get_info().is_golden() else 1):
				MinionUtils.add_stats(
					minion,
					minion,
					StatsUtils.mul_stats(Stats.new(1, 1), effect.get_value())
				)
			
class HaoQiDeLueDuoZhe extends MinionRoundEndAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			var info: CardInfo = CardUtils.create_minion_info(
				DataManager.get_sellable_minion_data().pick_random()
			)
			MinionUtils.golden(info)
			CardUtils.create_hand_card(info, minion.global_position, minion)

class JiRouLingZhuHuaMao extends MinionRoundEndAnimation:
	func play() -> void:
		for _minion in CardUtils.get_shopping_desk_card_collection().get_minion_collection().erase(minion).get_array():
			for i in range(2 if minion.get_info().is_golden() else 1):
				MinionUtils.add_stats(
					minion,
					_minion,
					StatsUtils.mul_stats(
						Stats.new(1, 1), 
						CardUtils.get_belong_player_effect(minion).find_effect(
							Effect_RoundUseMagic
						).get_value()+1
					)
				)

class AnChaoZhanLueZhuanJia extends MinionRoundEndAnimation:
	func play() -> void:
		if minion.get_info().get_boost_counter_info().get_count() < ShopConstant.get_max_level():
			minion.get_info().get_boost_counter_info().add_count(1)

class NaiXinDeZhenChaYuan extends MinionRoundEndAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().add_count(1)

class RouXinHaiYao extends MinionRoundEndAnimation:
	func play() -> void:
		DataManager.get_player_info().get_player_effect_collection().add_player_effect(
			Effect_SuZaoStatsBuff.new(
				Stats.new(4, 4) if minion.get_info().is_golden() else Stats.new(2, 2)
			)
		)
