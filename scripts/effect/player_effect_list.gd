class_name PlayerEffectList

var playerEffectList: Array[PlayerEffect] = []
 
func _init(effectList: Array[PlayerEffect]) -> void:
	for effect in effectList:
		add_effect(effect)

func remove_effect(effect: PlayerEffect) -> void:
	playerEffectList.erase(effect)

func get_list() -> Array[PlayerEffect]:
	return playerEffectList

func add_effect(effect: PlayerEffect) -> void:
	if not try_combine(effect):
		playerEffectList.append(effect)
	
func try_combine(effect: PlayerEffect) -> bool:
	for playerEffect in playerEffectList:
		if playerEffect.combine(effect):
			return true
	return false
