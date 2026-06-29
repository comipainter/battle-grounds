extends Control
class_name CoinComponent

enum CoinState { ACTIVE, PRE_DEACTIVATE, INACTIVE }

@onready var info: ShopInfo = DataManager.get_shop_info()
@onready var shop: ShopComponent = get_parent()

func init() -> void:
	if not info.coin_added.is_connected(add_coin):
		info.coin_added.connect(add_coin)
	if not info.coin_subed.is_connected(sub_coin):
		info.coin_subed.connect(sub_coin)
	shop.get_card_component().card_created.connect(
		func(card: Card):
			card.mouse_entered.connect(
				func(card: Card):
					if card.get_info().is_shopping_shop():
						# 预支金币
						pre_sub_coin(card.get_info().get_cost())
			)
			card.mouse_exited.connect(
				func(card: Card):
					if card.get_info().is_shopping_shop():
						# 撤销预支金币
						undo_pre_sub_coin(card.get_info().get_cost())
			)
			card.drag_started.connect(
				func(card: Card):
					# 预支铸币
					if card.get_info().is_shopping_shop():
						pre_sub_coin(card.get_info().get_cost())
			)
			card.drag_ended.connect(
				func(card: Card):
					# 取消预支铸币
					if card.get_info().is_shopping_shop():
						undo_pre_sub_coin(card.get_info().get_cost())
			)
	)

@onready var coinContainerSprite: Sprite2D = $CoinContainerSprite
@onready var coinNumberSprite: Sprite2D = $CoinNumberSprite
@onready var coinLabel: Label = $CoinLabel
@onready var coinContainer: VBoxContainer = $VBoxContainer

func use_info() -> void:
	if info == null:
		push_error("use info on coin component when info == null")
	else:
		coinContainerSprite.visible = true
		coinNumberSprite.visible = true
		coinContainer.visible = true
		coinLabel.visible = true

		coinLabel.text = str(info.get_coin()) + " / " + str(info.get_coin_limit())

		# 根据金币数量设置每个CoinSprite的状态
		var coin_count = info.get_coin()
		var coin_sprites = coinContainer.get_children()
		for i in range(coin_sprites.size()):
			var single_coin = coin_sprites[i]
			var coin_sprite = single_coin.get_node("CoinSprite") as Sprite2D
			if coin_sprite and coin_sprite.material is ShaderMaterial:
				var state = CoinState.ACTIVE if i < coin_count else CoinState.INACTIVE
				_set_coin_state(coin_sprite, state)

func add_coin(_added_coin: int) -> void:
	use_info()

func sub_coin(_subed_coin: int) -> void:
	use_info()

func pre_sub_coin(_pre_subed_coin: int) -> void:
	if info.get_coin() < _pre_subed_coin:
		return
	var coin_count = info.get_coin()
	var coin_sprites = coinContainer.get_children()
	for i in range(coin_sprites.size()):
		if i >= coin_count - _pre_subed_coin and i < coin_count:
			var single_coin = coin_sprites[i]
			var coin_sprite = single_coin.get_node("CoinSprite") as Sprite2D
			if coin_sprite and coin_sprite.material is ShaderMaterial:
				_set_coin_state(coin_sprite, CoinState.PRE_DEACTIVATE)

func undo_pre_sub_coin(_undo_pre_subed_coin: int) -> void:
	if info.get_coin() < _undo_pre_subed_coin:
		return
	var coin_count = info.get_coin()
	var coin_sprites = coinContainer.get_children()
	for i in range(coin_sprites.size()):
		if i >= coin_count - _undo_pre_subed_coin and i < coin_count:
			var single_coin = coin_sprites[i]
			var coin_sprite = single_coin.get_node("CoinSprite") as Sprite2D
			if coin_sprite and coin_sprite.material is ShaderMaterial:
				_set_coin_state(coin_sprite, CoinState.ACTIVE)


var _blend_tweens: Dictionary = {}  # 记录每个 coin_sprite 的 tween

func _set_coin_state(coin_sprite: Sprite2D, state: CoinState) -> void:
	var shader_mat = coin_sprite.material as ShaderMaterial

	# 停止该 coin_sprite 之前的 tween
	if _blend_tweens.has(coin_sprite):
		var old_tween = _blend_tweens[coin_sprite]
		if old_tween and old_tween.is_valid():
			old_tween.kill()
		_blend_tweens.erase(coin_sprite)

	match state:
		CoinState.ACTIVE:
			# 关闭预失活开关，灰色遮罩渐隐
			shader_mat.set_shader_parameter("pre_deactivate", false)
			var current_blend = shader_mat.get_shader_parameter("blend_factor")
			if abs(current_blend - 0.0) > 0.01:
				var tween = create_tween()
				_blend_tweens[coin_sprite] = tween
				tween.tween_method(
					func(value: float):
						shader_mat.set_shader_parameter("blend_factor", value),
					current_blend,
					0.0,
					0.3
				)

		CoinState.PRE_DEACTIVATE:
			# 打开预失活开关，展现黄光泛光闪烁
			shader_mat.set_shader_parameter("pre_deactivate", true)

		CoinState.INACTIVE:
			# 关闭预失活开关，灰色遮罩渐显
			shader_mat.set_shader_parameter("pre_deactivate", false)
			var current_blend = shader_mat.get_shader_parameter("blend_factor")
			if abs(current_blend - 1.0) > 0.01:
				var tween = create_tween()
				_blend_tweens[coin_sprite] = tween
				tween.tween_method(
					func(value: float):
						shader_mat.set_shader_parameter("blend_factor", value),
					current_blend,
					1.0,
					0.3
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
@export var _start_anim_offset: Vector2 = Vector2(-400, 0)
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
	
	tween.tween_callback(
		func():
			# 回合开始业务逻辑
			if info.get_coin_limit() + 1 <= info.get_coin_max_limit():
				info.set_coin_limit(info.get_coin_limit()+1)
			info.set_coin(info.get_coin_limit())
			use_info()
	)
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
