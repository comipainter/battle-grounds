extends Resource
class_name PlayerEffect

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
func _delete(_effect: PlayerEffect) -> void:
	deleted.emit(_effect)
	
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	pass

func _on_freshed() -> void:
	pass
	#return false # 返回真代表不删除，返回否代表删除

func _on_round_started() -> void:
	pass
		
func _on_round_ended() -> void:
	pass

func _on_used_minion(minion: Minion) -> void:
	pass
	
func _on_card_created(card: Card) -> void:
	pass
	
func _on_minion_attack_after(attackMinion: Minion, behitMinion: Minion) -> void:
	pass
	
func _on_used_magic(magic: Magic) -> void:
	pass
	
func _on_coin_subed(subed_coin: int) -> void:
	pass

func _on_fight_started(side: String) -> void:
	pass
