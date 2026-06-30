extends MinionComponent
class_name MinionHandDescriptionComponent

var info: MinionInfo
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info()
	
@onready var descriptionLabel: Label = $DescriptionLabel

func use_info() -> void:
	descriptionLabel.visible = true
	descriptionLabel.text = info.get_description()
	
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		descriptionLabel.visible = false
