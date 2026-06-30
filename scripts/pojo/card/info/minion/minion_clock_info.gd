extends Resource
class_name MinionClockInfo


@export var _clockAble: bool = false
func is_able() -> bool:
	return _clockAble
func set_able(value: bool) -> void:
	_clockAble = value

@export var _clockStoped: bool = false
func is_stop() -> bool:
	return _clockStoped
func set_stop(value: bool) -> void:
	_clockStoped = value

@export var _clockRoundTime: float = 1
func get_clock_round_time() -> float:
	return _clockRoundTime
func set_clock_round_time(value: float) -> void:
	_clockRoundTime = value

@export var _currDegree: float = 0.0
func get_curr_degree() -> float:
	return _currDegree
func set_curr_degree(value: float) -> void:
	_currDegree = value

@export var _clockFunction: MinionClockFunction = MinionClockFunction.new(func(): pass)
func get_clock_function() -> MinionClockFunction:
	return _clockFunction
func set_clock_function(value: MinionClockFunction) -> void:
	_clockFunction = value

func _init(
	_clock_able: bool = false,
	_clock_stoped: bool = false,
	_clock_round_time: float = 1.0,
	_curr_degree: float = 0.0,
	_clock_function: MinionClockFunction = null
) -> void:
	_clockAble = _clock_able
	_clockStoped = _clock_stoped
	_clockRoundTime = _clock_round_time
	_currDegree = _curr_degree
	_clockFunction = _clock_function if _clock_function else MinionClockFunction.new(func(): pass)
