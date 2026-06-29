### 攻击后
extends MinionAnimation
class_name MinionAttackAfterAnimation

var attackMinion: Minion = null
var behitMinion: Minion = null
func _init(_attackMinion: Minion, _behitMinion: Minion) -> void:
	attackMinion = _attackMinion
	behitMinion = _behitMinion
func play() -> void:
		pass
	
class YeHuoYuanSu extends MinionAttackBeforeAnimation:
	func play() -> void:
		var adjacentMinion: Minion = CardUtils.get_opponent_card_collection(
			attackMinion
		).get_minion_collection().get_adjacent_minions(
			behitMinion
		).pick_random()
		if adjacentMinion != null:
			adjacentMinion.get_info().take_damage(
				adjacentMinion.get_info().get_stats().get_health()+1
			)
