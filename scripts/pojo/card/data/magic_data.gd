extends CardData
class_name MagicData

func copy() -> MagicData:
	return duplicate(true)

@export var cost: int = 0
@export var suzao: bool = false

func get_cost() -> int:
	return cost
func is_suzao() -> bool:
	return suzao
