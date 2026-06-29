extends Control
class_name ShopFreshComponent

@onready var shopComponent: ShopComponent = get_parent()
@onready var info: ShopInfo = DataManager.get_shop_info()

signal button_up
signal freshed
func _on_fresh_button_button_up() -> void:
	if info.get_coin() >= info.get_fresh_cost():
		info.sub_coin(info.get_fresh_cost())
		fresh()
		# 刷新完后立即执行预支金币的相关代码
		shopComponent.get_coin_component().undo_pre_sub_coin(info.get_fresh_cost())
	button_up.emit()

func _on_fresh_button_mouse_entered() -> void:
	shopComponent.get_coin_component().pre_sub_coin(
		info.get_fresh_cost()
	)
	mouse_entered.emit()

func _on_fresh_button_mouse_exited() -> void:
	shopComponent.get_coin_component().undo_pre_sub_coin(
		info.get_fresh_cost()
	)
	mouse_exited.emit()

func fresh() -> void:
	var _collection: CardInfoCollection = CardInfoCollection.new().add_minion_collection(
		CardUtils.create_minion_info_collection(
			DataManager.get_sellable_minion_data().filter_by(
				MinionDataCollection.Filter.new().set_level_range(
					1, info.get_level()
				)
			).pick_random_collection(
				info.get_minion_num(),
				true
			)
		)
	).add_magic_collection(
		CardUtils.create_magic_info_collection(
			DataManager.get_sellable_magic_data().filter_by(
				MagicDataCollection.Filter.new().set_level_range(
					1, info.get_level()
				)
			).pick_random_collection(
				info.get_magic_num(),
				true
			)
		)
	)
	# 先清理所有商店卡牌
	info.delete_all_shop_card()
	# 再添加信息到商店
	for cardInfo in _collection.get_array():
		info.create_shop_card_info(cardInfo, Vector2(0, 0))
	#for i in range(_collection.get_array().size() - 1, -1, -1): # 使用倒序遍历
		#var cardInfo = _collection.get_array()[i]
		#info.create_shop_card_info(cardInfo, Vector2.ZERO)
	freshed.emit()


@onready var freshSprite: Sprite2D = $FreshSprite
@onready var freshButton: Button = $FreshButton
@onready var costSprite: Sprite2D = $CostSprite
@onready var cornerSprite: Sprite2D = $CornerSprite
@onready var costLabel: Label = $CostLabel

func update_cost() -> void:
	costLabel.text = str(info.get_fresh_cost())

# 初始化方法，由父节点的_ready方法或者init方法调用
func init() -> void:
	info.fresh_cost_changed.connect(update_cost)

# 控制使能方法
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
	# 开始动画
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
	
	tween.tween_callback(
		func():
			# 开始逻辑
			update_cost()
			fresh()
	)
	return tween.finished

# 关闭控件的方法
@export var _close_anim_duration: float = _start_anim_duration
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
