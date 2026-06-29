extends MagicComponent
class_name MagicBackgroundComponent

var info: MagicInfo
func set_magic(_magic: Magic):
	super.set_magic(_magic)
	info = _magic.get_info()

@onready var backgroundSprite: Sprite2D = $BackgroundSprite
@onready var magicSprite: Sprite2D = $MagicSprite

func use_info() -> void:
	backgroundSprite.visible = true
	magicSprite.visible = true
	set_sprite()
		
func set_sprite() -> void:
	if PathUtils.exist(info.get_spritePath()):
		magicSprite.texture = load(info.get_spritePath())

func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		backgroundSprite.visible = false
		magicSprite.visible = false
