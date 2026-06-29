extends Resource
class_name GameInfo

# 配置信息

@export var currRoundNum: int = 0

func set_curr_round_num(_num: int) -> void:
	currRoundNum = _num
func get_curr_round_num() -> int:
	return currRoundNum
	
@export var currPhaseNum: int = 0

func set_curr_phase_num(_num: int) -> void:
	currPhaseNum = _num
func get_curr_phase_num() -> int:
	return currPhaseNum

@export var state: GameState = GameState.new()
func is_menuing() -> bool:
	return state.is_menuing()
func is_shopping() -> bool:
	return state.is_shopping()
func is_fighting() -> bool:
	return state.is_fighting()
func set_menuing() -> void:
	state.set_menuing()
func set_shoping() -> void:
	state.set_shoping()
func set_fighting() -> void:
	state.set_fighting()
