extends Resource
class_name MinionEffectCollection

@export var array: Array[MinionEffect] = []

func get_array() -> Array[MinionEffect]:
	return array
		
func add_minion_effect(_effect: MinionEffect) -> void:
	array.append(_effect)
	_effect.deleted.connect(
		func(deleted_effect: MinionEffect):
			array.erase(deleted_effect)
	)
	_on_minion_effect_added(_effect)
	
func _on_minion_effect_added(_effect: MinionEffect) -> void:
	for effect in get_array().duplicate():
		effect._on_minion_effect_added(_effect)

func _on_round_started(minion: Minion) -> void:
	for effect in get_array().duplicate():
		effect._on_round_started(minion)
		#if effect is MinionEffect: # 不知道为什么这里面会有空Resource对象
			#effect._on_round_started()

func _on_round_ended(minion: Minion) -> void:
	for effect in get_array().duplicate():
		effect._on_round_ended(minion)

func _on_use_minion(minion: Minion) -> void:
	for effect in get_array().duplicate():
		effect._on_use_minion(minion)

func _on_dead_after(minion: Minion) -> void:
	var wangyu_count: int = 1
	for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
		if _minion.get_info().get_id() == 67:
			if _minion.get_info().is_golden():
				wangyu_count += 2
			else:
				wangyu_count += 1
	for i in range(wangyu_count):
		for effect in get_array().duplicate():
			effect._on_dead_after(minion)

func _on_processed(minion: Minion, delta: float) -> void:
	for effect in get_array().duplicate():
		effect._on_processed(minion, delta)
