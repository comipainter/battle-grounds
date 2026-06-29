extends MinionComponent
class_name MinionBoostCounterComponent

var info: MinionBoostCounterInfo = MinionBoostCounterInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info().get_boost_counter_info()
	info.count_changed.connect(
		use_info
	)
	
@onready var boostCounterLabel: Label = $BoostCounterLabel
@onready var boostCounterSprite: Sprite2D = $BoostCounterSprite

func use_info() -> void:
	boostCounterLabel.visible = info.is_able()
	boostCounterSprite.visible = info.is_able()
	boostCounterLabel.text = str(info.get_count())

func add_count(addCount: int) -> void:
	info.set_count(info.get_count() + addCount)

func close() -> void:
	boostCounterLabel.visible = false
	boostCounterSprite.visible = false
	use_info()

func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		close()
