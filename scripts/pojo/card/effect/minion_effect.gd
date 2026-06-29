extends Resource
class_name MinionEffect

@export var effect_name: String
func get_effect_name() -> String:
	return effect_name
@export var value: int = 0
func get_value() -> int:
	return value
@export var sprite_path: String = ""
func get_sprite_path() -> String:
	return sprite_path
	
func get_description() -> String:
	return effect_name + str(": ") + str(value)
	
signal deleted
func _delete(_effect: MinionEffect) -> void:
	deleted.emit(_effect)
	
func is_xifu_effect() -> bool:
	return false
	
func _on_minion_effect_added(_effect: MinionEffect) -> void:
	pass

func _on_round_started(minion: Minion) -> void:
	pass
	
func _on_shengdun_changed(new_shengdun: bool) -> void:
	pass
	
func _on_round_ended(minion: Minion) -> void:
	pass
	
func _on_use_minion(minion: Minion) -> void:
	pass
	
func _on_dead_after(minion: Minion) -> void:
	pass
	
func _on_processed(minion: Minion, delta: float) -> void:
	pass
