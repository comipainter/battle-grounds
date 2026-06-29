extends Control
class_name LevelComponent

@onready var shopComponent: ShopComponent = get_parent()
@onready var info: ShopInfo = DataManager.get_shop_info()

@onready var backgroundSprite: Sprite2D = $BackgroundSprite
@onready var level1: Control = $Level1
@onready var level2: Control = $Level2
@onready var level3: Control = $Level3
@onready var level4: Control = $Level4
@onready var level5: Control = $Level5
@onready var level6: Control = $Level6

func init() -> void:
	info.level_changed.connect(_update)
	
func set_able(_able: bool) -> void:
	backgroundSprite.visible = _able
	if _able:
		_update()
	else:
		level1.visible = false
		level2.visible = false
		level3.visible = false
		level4.visible = false
		level5.visible = false
		level6.visible = false

func _update() -> void:
	level1.visible = false
	level2.visible = false
	level3.visible = false
	level4.visible = false
	level5.visible = false
	level6.visible = false
	match info.get_level():
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

# 开启控件的方法
## 动画参数
## 动画总时间（秒），默认 0.6
@export var _start_anim_duration: float = 0.6
## 起始位置，默认当前位置正上方 80px
@export var _start_anim_offset: Vector2 = Vector2(0, -400)
func start() -> Signal:
	var _start_anim_end_pos: Vector2 = position
	position += _start_anim_offset
	var tween := create_tween()
	# TRANS_BACK: 到达终点后弹簧式回弹；EASE_IN: 前半段加速下落
	tween.tween_property(
		self, 
		"position", 
		_start_anim_end_pos, 
		_start_anim_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	return tween.finished

# 关闭控件的方法
## 动画总时间（秒），默认 0.4
@export var _close_anim_duration: float = _start_anim_duration
## 退出目标位置偏移，默认向上 400px
@export var _close_anim_offset: Vector2 = _start_anim_offset
func close() -> Signal:
	var _close_anim_end_pos: Vector2 = position + _close_anim_offset
	var _origin_pos: Vector2 = position
	var tween := create_tween()
	# EASE_IN: 越来越快地上移；TRANS_BACK 会在终点回弹
	tween.tween_property(
		self,
		"position",
		_close_anim_end_pos,
		_close_anim_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(
		func():
			set_able(false)
			position = _origin_pos
	)
	return tween.finished
