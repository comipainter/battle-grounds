extends MinionComponent
class_name MinionCounterComponent

var info: MinionCounterInfo = MinionCounterInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info().get_counter_info()
	info.activated.connect(
		func():
			MinionCounterFunction.activate(
				minion,
				MinionCounterManager.match(
					info.get_match_name()
				)
			)
	)
	info.able_changed.connect(use_info)
	info.count_changed.connect(use_info)
	info.limit_changed.connect(use_info)

@onready var counterLabel: Label = $CounterLabel

func _set_visible(_visible: bool) -> void:
	counterLabel.visible = _visible

func use_info() -> void:
	if info.is_able():
		_set_visible(true)
		counterLabel.text = str(
			str(info.get_count()) + " / " + str(info.get_limit())
		)
	else:
		_set_visible(false)

#func close() -> void:
	#info.set_able(false)
	#use_info()
#
#func start() -> void:
	#info.set_able(true)
	#use_info()
	
var able: bool = true
func set_able(_able: bool) -> void:
	if able == _able:
		return
	able = _able
	_set_visible(_able)
	use_info()

func _process(delta: float) -> void:
	pass
