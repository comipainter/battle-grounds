### ronghe
extends MinionAnimation
class_name MinionRongheAnimation

var ronghe_minion: Minion = null
var minion1: Minion = null
var minion2: Minion = null
func _init(_ronghe_minion: Minion, _minion1: Minion, _minion2: Minion) -> void:
	ronghe_minion = _ronghe_minion
	minion1 = _minion1
	minion2 = _minion2
func play() -> void:
	pass

class BuMieCanHe extends MinionRongheAnimation:
	func play() -> void:
		if is_instance_valid(ronghe_minion) and is_instance_valid(minion1) and is_instance_valid(minion2):
			ronghe_minion.get_info().add_stats(
				StatsUtils.mul_stats(
					StatsUtils.add_stats(
						minion1.get_info().get_stats(),
						minion2.get_info().get_stats()
					),
					3 if minion1.get_info().is_golden() else 2
				)
			)
			
