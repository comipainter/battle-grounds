### 出售
extends MinionAnimation
class_name MinionCoinSubAnimation

var subed_coin: int = 0
var minion: Minion = null
func _init(_subed_coin: int, _minion: Minion) -> void:
	subed_coin = _subed_coin
	minion = _minion
func play() -> void:
		pass
		
class KongJunShangJiangLuoJieSi extends MinionCoinSubAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().add_count(subed_coin)
