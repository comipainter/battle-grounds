extends Control
class_name BookComponent


@onready var sprite: Sprite2D = $BookSprite
@onready var button: Button = $BookButton


func _on_book_button_button_up() -> void:
	var book: Book = DataManager.bookScene.instantiate()
	add_child(book)
	book.global_position = Vector2(1280.0, 720.0)
	book.exited.connect(
		book.queue_free
	)

var able: bool = true
func set_able(_able):
	if able == _able:
		return
	if _able:
		self.visible = true
	else:
		self.visible = false
	able = _able


# 开启控件的方法
## 动画参数
## 动画总时间（秒），默认 0.6
@export var _start_anim_duration: float = 0.6
## 起始位置，默认当前位置正上方 80px
@export var _start_anim_offset: Vector2 = Vector2(0, 400)
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
