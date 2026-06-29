### 出售
extends MinionAnimation
class_name MinionBuyAnimation

var brought_card: Card = null
var minion: Minion = null
func _init(_brought_card: Card, _minion: Minion) -> void:
	brought_card = _brought_card
	minion = _minion
func play() -> void:
		pass
		
class ZhouFuHaiYuan extends MinionBuyAnimation:
	func play() -> void:
		if brought_card.get_info().is_minion():
			minion.get_info().get_counter_info().add_count(1)
