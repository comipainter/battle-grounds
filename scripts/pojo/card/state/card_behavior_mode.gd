extends Resource
class_name CardBehaviorMode

var mode: CardDefinition.Behavior = CardDefinition.Behavior.Follow

func set_follow() -> void:
	mode = CardDefinition.Behavior.Follow
func set_drag() -> void:
	mode = CardDefinition.Behavior.Drag
func set_none() -> void:
	mode = CardDefinition.Behavior.None

func is_follow() -> bool:
	return mode == CardDefinition.Behavior.Follow
func is_drag() -> bool:
	return mode == CardDefinition.Behavior.Drag
func is_none() -> bool:
	return mode == CardDefinition.Behavior.None
