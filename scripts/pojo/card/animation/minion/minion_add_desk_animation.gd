### 回合结束
extends MinionAnimation
class_name MinionAddDeskAnimation

var info_added: CardInfo
var minion: Minion = null
func _init(_info_added: CardInfo, _minion: Minion) -> void:
	minion = _minion
	info_added = _info_added

func play() -> void:
	pass
