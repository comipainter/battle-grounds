extends Resource
class_name MinionHitFunction

@export var function: Callable # 点击后触发用于

func _init(_function: Callable = Callable()):
	function = _function

func run(minion: Minion, position: Vector2) -> void:
	if function.get_argument_count() == 2:
		function.call(minion, position)
	elif function.get_argument_count() == 1:
		function.call(minion)
	else:
		function.call()
