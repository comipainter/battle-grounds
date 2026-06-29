class_name Effect_LastAttacker extends PlayerEffect
@export var _is_player:bool = false
@export var _is_enemy:bool = false
func _init() -> void:
	self.effect_name = "上一个攻击的攻击方"
	self.sprite_path = "res://assets/image/minion/亡灵舰长伊丽扎.png"
func _on_minion_attack_after(attackMinion: Minion, behitMinion: Minion) -> void:
	_is_player = attackMinion.get_info().is_player()
	_is_enemy = attackMinion.get_info().is_enemy()
func is_player() -> bool:
	return _is_player
func is_enemy() -> bool:
	return _is_enemy
func _on_round_started() -> void:
	_is_player = false
	_is_enemy = false
func get_description() -> String:
	return effect_name + "： " + str(
		"玩家" if _is_player else "敌方"
	)
