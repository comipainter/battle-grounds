### 复仇
extends MinionAnimation
class_name MinionDieAfterMinionAnimation

var dead_minion: Minion = null
var minion: Minion = null
func _init(_dead_minion: Minion, _minion: Minion) -> void:
	minion = _minion
	dead_minion = _dead_minion

func play() -> void:
	pass

class ShiTiTiLianShi extends MinionDieAfterMinionAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().add_count(1)

class HaiLangTiDaoHao extends MinionDieAfterMinionAnimation:
	func play() -> void:
		if minion.get_info().get_boost_counter_info().get_count() > 0:
			minion.get_info().get_counter_info().add_count(1)

class YiXinDiAoSi extends MinionDieAfterMinionAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().add_count(1)
