extends MinionComponent
class_name MinionHandNameComponent

var info: MinionInfo
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info()

@onready var nameSprite: Sprite2D = $NameSprite
@onready var nameLabel: HandNameLabel = $NameLabel

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
