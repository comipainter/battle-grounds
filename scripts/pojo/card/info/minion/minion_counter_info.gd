extends Resource
class_name MinionCounterInfo

@export var _counterAble: bool = false
func is_able() -> bool:
	return _counterAble
signal able_changed
func set_able(value: bool) -> void:
	_counterAble = value
	able_changed.emit()

@export var _count: int = 0
func get_count() -> int:
	return _count
signal count_changed
func set_count(value: int) -> void:
	_count = value
	count_changed.emit()

@export var _limit: int = 1
func get_limit() -> int:
	return _limit
signal limit_changed
func set_limit(value: int) -> void:
	_limit = value
	limit_changed.emit()

enum Mode{
	Normal,
	Contianer
}
@export var _mode: Mode = Mode.Normal
func get_mode() -> Mode:
	return _mode
func set_mode_normal() -> void:
	_mode = Mode.Normal
func set_mode_container() -> void:
	_mode = Mode.Contianer

@export var _match_name: String = ""
func get_match_name() -> String:
	return _match_name
func set_match_name(_name: String) -> void:
	_match_name = _name

func init(
	p_counterAble: bool = false,
	p_count: int = 0,
	p_limit: int = 1,
	p_mode: Mode = Mode.Normal,
	p_match_name: String = ""
) -> void:
	_counterAble = p_counterAble
	_count = p_count
	_limit = p_limit
	_mode = p_mode
	_match_name = p_match_name

signal activated
func add_count(addCount: int) -> void:
	match get_mode():
		MinionCounterInfo.Mode.Normal:
			set_count(get_count() + addCount)
			while get_count() >= get_limit():
				activated.emit()
				set_count(get_count() - get_limit())
		MinionCounterInfo.Mode.Contianer:
			set_count(
				mini(get_count() + addCount, get_limit())
			)
			if get_count() == get_limit():
				activated.emit()

func create_count(p_count:int, p_limit:int, p_mode:String, p_match_name: String) -> void:
	set_able(true)
	match p_mode:
		"normal": 
			set_mode_normal()
			set_count(p_count)
			set_limit(p_limit)
			set_match_name(p_match_name)
		"container":
			set_mode_container()
			set_count(p_count)
			set_limit(p_limit)
			set_match_name(p_match_name)
