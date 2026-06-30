extends MinionComponent
class_name MinionHandRaceComponent

var info: MinionInfo
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info()

@onready var raceSprite: Sprite2D = $RaceSprite
@onready var raceLabel: Label = $RaceLabel

func use_info() -> void:
	raceLabel.visible = true
	raceSprite.visible = true
	raceLabel.text = MinionUtils.get_race_name(info.get_race())
	
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		raceLabel.visible = false
		raceSprite.visible = false
