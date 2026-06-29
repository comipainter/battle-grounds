extends Resource
class_name MinionBoostCounterInfo

@export var _counterAble: bool = false
func is_able() -> bool:
	return _counterAble
func set_able(value: bool) -> void:
	_counterAble = value

@export var _count: int = 0
func get_count() -> int:
	return _count
func set_count(value: int) -> void:
	_count = value

func init(
	p_counterAble: bool = false,
	p_count: int = 0,
) -> void:
	_counterAble = p_counterAble
	_count = p_count

func create(p_count: int) -> void:
	_counterAble = true
	_count = p_count
	count_changed.emit()
	
signal count_changed
func add_count(_add_count: int) -> void:
	_count += _add_count
	count_changed.emit()
