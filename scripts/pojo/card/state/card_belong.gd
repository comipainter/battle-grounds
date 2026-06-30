extends Resource
class_name CardBelong

@export var type: CardDefinition.Belong = CardDefinition.Belong.None

func set_shopping_shop() -> void:
	type = CardDefinition.Belong.Shoping_Shop
func set_shopping_desk() -> void:
	type = CardDefinition.Belong.Shopping_Desk
func set_shopping_hand() -> void:
	type = CardDefinition.Belong.Shopping_Hand
func set_shopping_free() -> void:
	type = CardDefinition.Belong.Shopping_Free
func set_enemy_desk() -> void:
	type = CardDefinition.Belong.Enemy_Desk
func set_enemy_hand() -> void:
	type = CardDefinition.Belong.Enemy_Hand
func set_player_desk() -> void:
	type = CardDefinition.Belong.Player_Desk
func set_player_hand() -> void:
	type = CardDefinition.Belong.Player_Hand
func set_player_free() -> void:
	type = CardDefinition.Belong.Player_Free
func set_enemy_free() -> void:
	type = CardDefinition.Belong.Enemy_Free
func set_none() -> void:
	type = CardDefinition.Belong.None

func is_shopping_shop() -> bool:
	return type == CardDefinition.Belong.Shoping_Shop
func is_shopping_desk() -> bool:
	return type == CardDefinition.Belong.Shopping_Desk
func is_shopping_hand() -> bool:
	return type == CardDefinition.Belong.Shopping_Hand
func is_shopping_free() -> bool:
	return type == CardDefinition.Belong.Shopping_Free
func is_enemy_desk() -> bool:
	return type == CardDefinition.Belong.Enemy_Desk
func is_enemy_hand() -> bool:
	return type == CardDefinition.Belong.Enemy_Hand
func is_player_desk() -> bool:
	return type == CardDefinition.Belong.Player_Desk
func is_player_hand() -> bool:
	return type == CardDefinition.Belong.Player_Hand
func is_player_free() -> bool:
	return type == CardDefinition.Belong.Player_Free
func is_enemy_free() -> bool:
	return type == CardDefinition.Belong.Enemy_Free
func is_none() -> bool:
	return type == CardDefinition.Belong.None

func is_player() -> bool:
	return is_player_desk() or is_player_hand() or is_player_free()

func is_enemy() -> bool:
	return is_enemy_desk() or is_enemy_hand() or is_enemy_free()

func is_shopping() -> bool:
	return is_shopping_shop() or is_shopping_desk() or is_shopping_hand()
