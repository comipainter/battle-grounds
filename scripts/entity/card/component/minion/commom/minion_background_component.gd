extends MinionComponent
class_name MinionBackgroundComponent

var info: MinionInfo
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info()

@onready var backgroundSprite: Sprite2D = $BackgroundSprite
@onready var goldenBackgroundSprite: Sprite2D = $GoldenBackgroundSprite
@onready var minionSprite: Sprite2D = $MinionSprite

@onready var ronghe: Control = $Ronghe
@onready var rongheSprite: Sprite2D = $Ronghe/MinionSprite
@onready var rongheSprite2: Sprite2D = $Ronghe/MinionSprite2

func use_info() -> void:
	if info.is_golden():
		backgroundSprite.visible = false
		goldenBackgroundSprite.visible = true
	else:
		backgroundSprite.visible = true
		goldenBackgroundSprite.visible = false
	set_sprite()
		
func set_sprite() -> void:
	if info.is_ronghe():
		ronghe.visible = true
		minionSprite.visible = false
		var textureList: Array[Texture2D] = []
		for baseInfo in info.get_base_info_array():
			textureList.append(load(baseInfo.get_spritePath()))
		rongheSprite.texture_list = textureList
		rongheSprite.start = true
		return
	if PathUtils.exist(info.get_spritePath()):
		minionSprite.visible = true
		minionSprite.texture = load(info.get_spritePath())

func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		backgroundSprite.visible = false
		goldenBackgroundSprite.visible = false
		minionSprite.visible = false
		ronghe.visible = false
