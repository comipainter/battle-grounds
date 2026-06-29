extends MagicComponent
class_name MagicHandDescriptionComponent

var info: MagicInfo
func set_magic(_magic: Magic):
	super.set_magic(_magic)
	info = _magic.get_info()

@onready var descriptionLabel: Label = $DescriptionLabel

func use_info() -> void:
	descriptionLabel.visible = true
	descriptionLabel.text = info.get_description()
		
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		descriptionLabel.visible = false
