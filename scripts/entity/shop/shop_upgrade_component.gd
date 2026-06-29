extends Control
class_name ShopUpgradeComponent

@onready var shopComponent: ShopComponent = get_parent()
@onready var info: ShopInfo = DataManager.get_shop_info()

@onready var costLabel: Label = $CostLabel
func _process(delta: float) -> void:
	if DataManager.get_shop_info().get_upgrade_cost() != -1:
		costLabel.text = str(DataManager.get_shop_info().get_upgrade_cost())
	else:
		costLabel.text = "M"
		
func _on_upgrade_button_mouse_entered() -> void:
	# 预支金币
	if info.get_level() != info.get_max_level():
		shopComponent.get_coin_component().pre_sub_coin(
			info.get_upgrade_cost()
		)
	mouse_entered.emit()

func _on_upgrade_button_mouse_exited() -> void:
	# 撤销预支金币
	if info.get_level() != info.get_max_level():
		shopComponent.get_coin_component().undo_pre_sub_coin(
			info.get_upgrade_cost()
	)
	mouse_exited.emit()

signal button_up
func _on_upgrade_button_button_up() -> void:
	# 升级
	if info.get_level() != info.get_max_level():
		if info.get_coin() >= info.get_upgrade_cost():
			info.sub_coin(info.get_upgrade_cost())
			_upgrade()
			# 升级完后立即执行预支金币的相关代码
			if info.get_level() != info.get_max_level():
				shopComponent.get_coin_component().pre_sub_coin(
					info.get_upgrade_cost()
				)
	button_up.emit()

signal upgraded
func _upgrade() -> void:
	if info.get_level() < info.get_max_level():
		info.set_level(info.get_level() + 1)
	else:
		return
	upgraded.emit()

func init() -> void:
	pass
	
func round_end() -> void:
	# 回合结束时升级费用减一
	if info.get_upgrade_cost() >= 0:
		info.set_upgrade_cost(info.get_upgrade_cost()-1, info.get_level()+1)

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
