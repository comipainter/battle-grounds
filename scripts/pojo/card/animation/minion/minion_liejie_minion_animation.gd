### 裂解
extends MinionAnimation
class_name MinionLiejieMinionAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion
func play() -> void:
		pass

class ZengQiangDeGuangYaoZhiZi extends MinionLiejieMinionAnimation:
	func play() -> void:
		DataManager.get_player_info().get_player_effect_collection().add_player_effect(
			Effect_YuanSuStatsBuff.new(
				Stats.new(2, 2)if minion.get_info().is_golden() else Stats.new(1, 1)
			)
		)
