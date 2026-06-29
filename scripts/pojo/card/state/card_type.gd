extends Resource
class_name CardType

@export var type: CardDefinition.Type = CardDefinition.Type.None

func set_minion() -> void:
	type = CardDefinition.Type.Minion
func set_magic() -> void:
	type = CardDefinition.Type.Magic

func is_minion() -> bool:
	return type == CardDefinition.Type.Minion
func is_magic() -> bool:
	return type == CardDefinition.Type.Magic
