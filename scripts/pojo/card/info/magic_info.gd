extends CardInfo
class_name MagicInfo

func copy() -> MagicInfo:
	return duplicate(true)

@export var cost: int = 0
func set_cost(_cost: int) -> void:
	cost = _cost
func get_cost() -> int:
	return cost

@export var suzao: bool = false
func set_suzao(_suzao: bool) -> void:
	suzao = _suzao
func is_suzao() -> bool:
	return suzao

@export var boostCounterInfo: MagicBoostCounterInfo = MagicBoostCounterInfo.new()
func get_boost_counter_info() -> MagicBoostCounterInfo:
	return boostCounterInfo
func set_boost_counter_info(_boostCounterInfo: MagicBoostCounterInfo) -> void:
	boostCounterInfo = _boostCounterInfo
