extends Node

func match(
	counter_name: String
) -> MinionEffect:
	if not _map.has(counter_name):
		return null
	return _map[counter_name].call()

func _register(
	counter_name: String,
	init_func: Callable
) -> void:
	if not _map.has(counter_name):
		_map[counter_name] = {}
	_map[counter_name] = init_func
	
var _map: Dictionary = {}

func _ready() -> void:
	_registry()

func _registry() -> void:
	_register(
		"科技元素体",
		MinionEffect_KeJiYuanSuTi.new
	)
