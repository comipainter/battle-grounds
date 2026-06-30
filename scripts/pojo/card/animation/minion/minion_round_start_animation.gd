### 回合结束
extends MinionAnimation
class_name MinionRoundStartAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion
func play() -> void:
		pass

class TouJinDaoDanGui extends MinionRoundStartAnimation:
	func play() -> void:
		# 统计场上金色随从
		var num: int = 0
		for info in DataManager.get_shop_info().get_desk_info_collection().get_minion_collection().get_array():
			if info.is_golden():
				num += 1
		for i in range(num+1):
			DataManager.get_shop_info().add_coin(4 if minion.get_info().is_golden() else 2)

class HaiShangShuangXiong extends MinionRoundStartAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"海潮的祝福"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class ZaShuaQiShuShi extends MinionRoundStartAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"奇术杂耍"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class ReQingShaChuiShou extends MinionRoundStartAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			1,
			"container",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func():pass)
		)

class ChengBoQishi extends MinionRoundStartAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"骑士的祝福"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class GuShenDeWeiShi extends MinionRoundStartAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"古神的祝福"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class HuaDaoHuaXingZhe extends MinionRoundStartAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"滑道滑行术"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class AnChaoZhanLueZhuanJia extends MinionRoundStartAnimation:
	func play() -> void:
		var _level: int = minion.get_info().get_boost_counter_info().get_count()
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"暗流涌动"
						)
					).pick_random()
				),
				minion.global_position,
				minion,
				func(card: Card):
					(card as Magic).get_info().get_boost_counter_info().create(
						_level
					)
			)
		
class XiLiWaZi extends MinionRoundStartAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().set_count(0)

class JinQiangGeLeiTa extends MinionRoundStartAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"金色大衍术"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)
