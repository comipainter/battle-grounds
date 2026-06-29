extends Resource
class_name PlayerEffectCollection

@export var array: Array[PlayerEffect] = [
	Effect_RoundUseYuanSu.new(),
	Effect_LastAttacker.new(),
	Effect_UseMagic.new(),
	Effect_UseShenchenlandiao.new(),
	Effect_RoundUseMagic.new(),
	Effect_RoundMagicRecord.new(),
	Effect_YuanSuStatsBuff.new(),
	Effect_SuZaoStatsBuff.new()
]

func get_array() -> Array[PlayerEffect]:
	return array
		
func add_player_effect(_effect: PlayerEffect) -> void:
	array.append(_effect)
	_effect.deleted.connect(
		func(deleted_effect: PlayerEffect):
			array.erase(deleted_effect)
	)
	_on_player_effect_added(_effect)
	
func find_effect(_effect_script: GDScript) -> PlayerEffect:
	for effect in get_array():
		if effect.get_script() == _effect_script: 
			return effect
	return null
	
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	for effect in get_array().duplicate():
		effect._on_player_effect_added(_effect)

func _on_freshed() -> void:
	for effect in get_array().duplicate():
		effect._on_freshed()

func _on_round_started() -> void:
	for effect in get_array().duplicate():
		effect._on_round_started()
		
func _on_round_ended() -> void:
	for effect in get_array().duplicate():
		effect._on_round_ended()

func _on_used_minion(minion: Minion) -> void:
	for effect in get_array().duplicate():
		effect._on_used_minion(minion)

func _on_card_created(card: Card) -> void:
	for effect in get_array().duplicate():
		effect._on_card_created(card)

func _on_minion_attack_after(attackMinion: Minion, behitMinion: Minion) -> void:
	for effect in get_array().duplicate():
		effect._on_minion_attack_after(attackMinion, behitMinion)

func _on_used_magic(magic: Magic) -> void:
	for effect in get_array().duplicate():
		effect._on_used_magic(magic)

func _on_coin_subed(_subed_coin: int) -> void:
	for effect in get_array().duplicate():
		effect._on_coin_subed(_subed_coin)

func _on_fight_started(side: String) -> void:
	for effect in get_array().duplicate():
		effect._on_fight_started(side)
