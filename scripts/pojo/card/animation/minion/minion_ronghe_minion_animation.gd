### ronghe
extends MinionAnimation
class_name MinionRongheMinionAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion
func play() -> void:
		pass
		
class ZengQiangDeGuangYaoZhiZi extends MinionRongheMinionAnimation:
	func play() -> void:
		DataManager.get_player_info().get_player_effect_collection().add_player_effect(
			Effect_YuanSuStatsBuff.new(
				Stats.new(1, 1)
			)
		)
