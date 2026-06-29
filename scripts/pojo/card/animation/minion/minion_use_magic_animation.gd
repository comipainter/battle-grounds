# 使用随从
extends MinionAnimation
class_name MinionUseMagicAnimation

var usedMagic: Magic = null
var minion: Minion = null
func _init(_usedMagic: Magic, _minion: Minion) -> void:
	usedMagic = _usedMagic
	minion = _minion
func play() -> void:
		pass

class ShiKongChuanZhangGouWei extends MinionUseMagicAnimation:
	func play() -> void:
		for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
			MinionUtils.add_stats(
				minion,
				_minion,
				Stats.new(2, 0) if minion.get_info().is_golden() else Stats.new(1, 0)
			)

class JiaoDouShi extends MinionUseMagicAnimation:
	func play() -> void:
		MinionUtils.add_stats_from_magic(
			usedMagic,
			minion,
			Stats.new(0, 2) if minion.get_info().is_golden() else Stats.new(0, 1),
		)

class PoSuiZhuMu extends MinionUseMagicAnimation:
	func play() -> void:
		for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
			MinionUtils.add_stats(
				minion,
				_minion,
				Stats.new(0, 6) if minion.get_info().is_golden() else Stats.new(0, 3)
			)
