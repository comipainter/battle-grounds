### 攻击后
extends MinionAnimation
class_name MinionAttackIngAnimation

var attackMinion: Minion = null
var behitMinion: Minion = null
func _init(_attackMinion: Minion, _behitMinion: Minion) -> void:
	attackMinion = _attackMinion
	behitMinion = _behitMinion
func play() -> void:
		pass
	

			
