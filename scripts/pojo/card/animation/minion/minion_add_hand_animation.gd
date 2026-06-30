### 回合结束
extends MinionAnimation
class_name MinionAddHandAnimation

var info_added: CardInfo
var minion: Minion = null
func _init(_info_added: CardInfo, _minion: Minion) -> void:
	minion = _minion
	info_added = _info_added

func play() -> void:
	pass

class DeLuSiTe extends MinionAddHandAnimation:
	func play() -> void:
		for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
			if _minion.get_info().is_golden():
				MinionUtils.add_stats(
					minion,
					_minion,
					Stats.new(2,2) if minion.get_info().is_golden() else Stats.new(1,1)
				)
			MinionUtils.add_stats(
				minion,
				_minion,
				Stats.new(2,2) if minion.get_info().is_golden() else Stats.new(1,1)
			)
			
class DaChuNuoMi extends MinionAddHandAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().add_count(1)
