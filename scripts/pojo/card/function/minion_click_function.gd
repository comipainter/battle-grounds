extends Resource
class_name MinionClickFunction

@export var function: Callable # 点击后触发用于

func _init(_function: Callable = Callable()):
	function = _function

func run(minion: Minion, position: Vector2) -> String:
	if function.get_argument_count() == 2:
		return function.call(minion, position)
	elif function.get_argument_count() == 1:
		return function.call(minion)
	else:
		return function.call()
