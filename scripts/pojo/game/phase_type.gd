extends Resource
class_name PhaseType

@export var type: GameDefinition.Phase = GameDefinition.Phase.None

func is_shop() -> bool:
	return type == GameDefinition.Phase.Shop
func set_shop() -> void:
	type = GameDefinition.Phase.Shop
	
func is_fight_start() -> bool:
	return type == GameDefinition.Phase.Fight_Start
func set_fight_start() -> void:
	type = GameDefinition.Phase.Fight_Start

func is_fight_end() -> bool:
	return type == GameDefinition.Phase.Fight_End
func set_fight_end() -> void:
	type = GameDefinition.Phase.Fight_End
