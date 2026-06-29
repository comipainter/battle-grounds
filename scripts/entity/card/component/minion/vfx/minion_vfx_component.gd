extends MagicComponent
class_name MinionVfxComponent

@onready var shopColorrect: ColorRect = $Shop/ColorRect
@onready var handColorrect: ColorRect = $Hand/ColorRect
@onready var deskColorrect: ColorRect = $Desk/ColorRect

func set_shop_vfx_able(_able: bool) -> void:
	shopColorrect.visible = _able
	if _able:
		handColorrect.visible = false
		deskColorrect.visible = false

func set_hand_vfx_able(_able: bool) -> void:
	handColorrect.visible = _able
	if _able:
		deskColorrect.visible = false
		shopColorrect.visible = false

func set_desk_vfx_able(_able: bool) -> void:
	deskColorrect.visible = _able
	if _able:
		handColorrect.visible = false
		shopColorrect.visible = false

func _ready() -> void:
	set_shop_vfx_able(false)
	set_hand_vfx_able(false)
	set_desk_vfx_able(false)
