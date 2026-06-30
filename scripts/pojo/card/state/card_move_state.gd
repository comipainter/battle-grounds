extends Resource
class_name CardMoveState

var moveStop: CardDefinition.MoveState = CardDefinition.MoveState.Stop

func set_move() -> void:
	moveStop = CardDefinition.MoveState.Move
func set_stop() -> void:
	moveStop = CardDefinition.MoveState.Stop

func is_move() -> bool:
	return moveStop == CardDefinition.MoveState.Move
func is_stop() -> bool:
	return moveStop == CardDefinition.MoveState.Stop
