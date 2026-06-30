extends Resource
class_name GameState

var gameState: GameDefinition.State = GameDefinition.State.None

func is_menuing() -> bool:
	return gameState == GameDefinition.State.Menuing
func is_shopping() -> bool:
	return gameState == GameDefinition.State.Shopping
func is_fighting() -> bool:
	return gameState == GameDefinition.State.Fighting
func set_menuing() -> void:
	gameState = GameDefinition.State.Menuing
func set_shoping() -> void:
	gameState = GameDefinition.State.Shopping
func set_fighting() -> void:
	gameState = GameDefinition.State.Fighting
