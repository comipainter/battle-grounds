extends MagicComponent
class_name MagicCostComponent

var info: MagicInfo
func set_magic(_magic: Magic):
	super.set_magic(_magic)
	info = _magic.get_info()

@onready var costLabel: Label = $CostLabel
@onready var costSprite: Sprite2D = $CoinSprite

func use_info() -> void:
	costLabel.visible = true
	costSprite.visible = true
	costLabel.text = str(info.get_cost())

func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		costLabel.visible = false
		costSprite.visible = false
