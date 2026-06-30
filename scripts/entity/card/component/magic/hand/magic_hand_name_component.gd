extends MagicComponent
class_name MagicHandNameComponent

var info: MagicInfo
func set_magic(_magic: Magic):
	super.set_magic(_magic)
	info = _magic.get_info()

@onready var nameLabel: HandNameLabel = $NameLabel
@onready var nameSprite: Sprite2D = $NameSprite

func use_info() -> void:
	nameLabel.visible = true
	nameSprite.visible = true
	nameLabel.text = info.get_card_name()
		
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		nameLabel.visible = false
		nameSprite.visible = false
