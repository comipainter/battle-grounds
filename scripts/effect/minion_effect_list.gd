class_name MinionEffectList

var effectList: Array[MinionEffect] = []

func duplicate() -> MinionEffectList:
	var copy = MinionEffectList.new()
	for effect in effectList:
		copy.effectList.append(effect.duplicate())
	return copy

func get_list() -> Array[MinionEffect]:
	return effectList

func round_start(minion: Minion) -> void:
	var removeList: Array[MinionEffect] = []
	for effect in effectList:
		if effect.round_start(minion):
			removeList.append(effect)
	for effect in removeList:
		effectList.erase(effect)

func add_effect(minionEffect: MinionEffect) -> bool:
	if not try_combine(minionEffect):
		effectList.append(minionEffect)
		return true
	return false
	
func try_combine(minionEffect: MinionEffect) -> bool:
	for effect in effectList:
		if effect.combine(minionEffect):
			return true
	return false
