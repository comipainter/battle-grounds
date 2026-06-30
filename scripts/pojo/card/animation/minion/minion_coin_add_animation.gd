### 出售
extends MinionAnimation
class_name MinionCoinAddAnimation

var added_coin: int = 0
var minion: Minion = null
func _init(_added_coin: int, _minion: Minion) -> void:
	added_coin = _added_coin
	minion = _minion
func play() -> void:
		pass
		
class JinBiZhaPianFan extends MinionCoinAddAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().add_count(added_coin)
