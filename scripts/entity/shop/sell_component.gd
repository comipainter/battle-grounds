extends Control
class_name SellComponent

@onready var shopComponent: ShopComponent = get_parent()
@onready var areaComponent: AreaComponent = $Sellarea

@onready var info: ShopInfo = DataManager.get_shop_info()

func init() -> void:
	shopComponent.get_card_component().card_created.connect(
		func(card: Card):
			card.mouse_up.connect(
				func(card: Card):
					if _check_can_sell(card, get_global_mouse_position()):
						sell(card)
			)
	)
	
func _check_can_sell(card: Card, _position: Vector2) -> bool:
	if card.get_info().is_shopping_desk():
		if areaComponent.is_inside(_position):
			return true
	return false

signal sold(card)
func sell(card: Card) -> void:
	if card.is_in_group("minion"):
		sold.emit(card)
		card.add_animation(MinionAnimation.SoldAnimation.new(card))
		info.add_coin(1)

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
@export var _start_anim_offset: Vector2 = Vector2(400, 0)
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
