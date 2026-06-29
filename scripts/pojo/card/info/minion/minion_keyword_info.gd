extends Resource
class_name MinionKeywordInfo

@export var _shengdun: bool = false
func is_shengdun() -> bool:
	return _shengdun
signal shengdun_changed(value: bool)
func set_shengdun(value: bool) -> void:
	_shengdun = value
	shengdun_changed.emit(value)

@export var _chaofeng: bool = false
func is_chaofeng() -> bool:
	return _chaofeng
signal chaofeng_changed(value: bool)
func set_chaofeng(value: bool) -> void:
	_chaofeng = value
	chaofeng_changed.emit(value)

@export var _fengnu: bool = false
func is_fengnu() -> bool:
	return _fengnu
signal fengnu_changed(value: bool)
func set_fengnu(value: bool) -> void:
	_fengnu = value
	fengnu_changed.emit(value)

func _init(
	_shengdun_val: bool = false,
	_chaofeng_val: bool = false,
	_fengnu_val: bool = false
) -> void:
	_shengdun = _shengdun_val
	_chaofeng = _chaofeng_val
	_fengnu = _fengnu_val
