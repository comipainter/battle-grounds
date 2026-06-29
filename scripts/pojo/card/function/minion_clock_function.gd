extends Resource
class_name MinionClockFunction

@export var function: Callable

func _init(_function: Callable = Callable()):
	function = _function

func run(minion: Minion) -> void:
	if function.get_argument_count() > 0:
		function.call(minion)
	else:
		function.call()
