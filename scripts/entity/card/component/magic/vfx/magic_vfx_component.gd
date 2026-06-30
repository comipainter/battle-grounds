extends MagicComponent
class_name MagicVfxComponent

@onready var shopColorrect: ColorRect = $Shop/ColorRect
@onready var handColorrect: ColorRect = $Hand/ColorRect

func set_shop_vfx_able(_able: bool) -> void:
	shopColorrect.visible = _able

func set_hand_vfx_able(_able: bool) -> void:
	handColorrect.visible = _able

func _ready() -> void:
	set_shop_vfx_able(false)
	set_hand_vfx_able(false)
