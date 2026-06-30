extends Component
class_name CardLevelComponent

var level: int = 1
func set_level(_level: int) -> void:
	level = _level
	
@onready var levelBackgroundSprite: Sprite2D = $LevelBackgroundSprite
@onready var level1: Control = $Level1
@onready var level2: Control = $Level2
@onready var level3: Control = $Level3
@onready var level4: Control = $Level4
@onready var level5: Control = $Level5
@onready var level6: Control = $Level6

func use_info() -> void:
	levelBackgroundSprite.visible = true
	level1.visible = false
	level2.visible = false
	level3.visible = false
	level4.visible = false
	level5.visible = false
	level6.visible = false
	match level:
		1:
			level1.visible = true
		2:
			level2.visible = true
		3:
			level3.visible = true
		4:
			level4.visible = true
		5:
			level5.visible = true
		6:
			level6.visible = true
	
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		levelBackgroundSprite.visible = false
		level1.visible = false
		level2.visible = false
		level3.visible = false
		level4.visible = false
		level5.visible = false
		level6.visible = false
