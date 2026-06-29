extends Node2D
class_name Card

var info: CardInfo
func set_info(_info: CardInfo) -> void:
	info = _info
func use_info() -> void:
	pass
func get_info() -> CardInfo:
	return info
	
@onready var animationComponent: CardAnimationComponent = $Animation
func get_animation_component() -> CardAnimationComponent:
	return animationComponent
func add_animation(_animation: BaseAnimation) -> void:
	get_animation_component().add_animation(_animation)

@onready var moveComponent: CardMoveComponent = $Move
func get_move_component() -> CardMoveComponent:
	return moveComponent
	
signal drag_started(card: Card)
signal drag_ended(card: Card)
signal dragging(card: Card)

func follow(target: Control) -> void:
	moveComponent.set_target(target)
	moveComponent.set_follow()
	
func is_idle() -> bool:
	return get_animation_component().is_idle() and get_move_component().is_idle()

@onready var interactionComponent: CardInteractionComponent = $Interaction
func get_interaction_component() -> CardInteractionComponent:
	return interactionComponent
	
signal hover_started(card: Card)
signal hover_ended(card: Card)
signal clicked(card: Card)
signal mouse_entered(card: Card)
signal mouse_exited(card: Card)
signal mouse_down(card: Card)
signal mouse_up(card: Card)

func _ready() -> void:
	interactionComponent.hover_started.connect(
		func():
			on_hover_started()
			hover_started.emit(self)
	)
	interactionComponent.hover_ended.connect(
		func():
			on_hover_ended()
			hover_ended.emit(self)
	)
	interactionComponent.clicked.connect(
		func():
			on_clicked()
			clicked.emit(self)
	)
	interactionComponent.mouse_entered.connect(
		func():
			on_mouse_entered()
			mouse_entered.emit(self)
	)
	interactionComponent.mouse_exited.connect(
		func():
			on_mouse_exited()
			mouse_exited.emit(self)
	)
	interactionComponent.mouse_down.connect(
		func():
			on_mouse_down()
			moveComponent.set_drag()
			mouse_down.emit(self)
	)
	interactionComponent.mouse_up.connect(
		func():
			on_mouse_up()
			moveComponent.set_follow()
			mouse_up.emit(self)
	)
	moveComponent.start_drag.connect(
		func():
			on_drag_started()
			drag_started.emit(self)
	)
	moveComponent.end_drag.connect(
		func():
			on_drag_ended()
			drag_ended.emit(self)
	)
	moveComponent.dragging.connect(
		func():
			on_dragging()
			dragging.emit(self)
	)

func on_hover_started() -> void:
	pass

func on_hover_ended() -> void:
	pass
	
func on_clicked() -> void:
	pass

func on_mouse_entered() -> void:
	# 手牌选中相关
	if get_info().is_player_hand():
		set_player_hand_mouse_entered()
	elif get_info().is_shopping_hand():
		set_shopping_hand_mouse_entered()
	# 商店选中相关
	elif get_info().is_shopping_shop():
		set_shopping_shop_mouse_entered()
	# 场上选中相关
	elif get_info().is_shopping_desk(): 
		set_shopping_desk_mouse_entered()
	
func on_mouse_exited() -> void:
	# 手牌选中相关
	if get_info().is_shopping_hand() and get_move_component().is_drag() == false:
		set_shopping_hand_mouse_exited()
	if get_info().is_player_hand() and get_move_component().is_drag() == false:
		set_player_hand_mouse_exited()
	# 商店选中相关
	elif get_info().is_shopping_shop() and get_move_component().is_drag() == false:
		set_shopping_shop_mouse_exited()
	# 场上选中相关
	elif get_info().is_shopping_desk() and get_move_component().is_drag() == false:
		set_shopping_desk_mouse_exited()

func on_mouse_down() -> void:
	# 手牌选中相关
	if get_info().is_shopping_hand():
		set_shopping_hand_mouse_down()
	if get_info().is_player_hand():
		set_player_hand_mouse_down()
	# 商店选中相关
	if get_info().is_shopping_shop():
		set_shopping_shop_mouse_down()
	# 场上选中相关
	if get_info().is_shopping_desk():
		set_shopping_desk_mouse_down()
	
func on_mouse_up() -> void:
	# 手牌选中相关
	if get_info().is_shopping_hand():
		set_shopping_hand_mouse_up()
	if get_info().is_player_hand():
		set_player_hand_mouse_up()
	# 商店选中相关
	if get_info().is_shopping_shop():
		set_shopping_shop_mouse_up()
	# 场上选中相关
	if get_info().is_shopping_desk():
		set_shopping_desk_mouse_up()
	
func on_drag_started() -> void:
	pass

func on_drag_ended() -> void:
	pass
	
func on_dragging() -> void:
	pass

# 在手牌中的选中模式展示逻辑
@export var handMouseEnteredScale: Vector2 = Vector2(1.5, 1.5)
@export var handButtonDownScale: Vector2 = Vector2(0.75, 0.75)

var _hand_scale_tween: Tween = null

func set_player_hand_mouse_entered() -> void:
	# 只有没执行拖拽和跟随逻辑时才触发
	if get_move_component().is_stop() == false:
		return 
	# 缩放动画
	if _hand_scale_tween and _hand_scale_tween.is_valid():
		_hand_scale_tween.kill()
	_hand_scale_tween = create_tween()
	_hand_scale_tween.tween_property(self, "scale", handMouseEnteredScale, 0.05)

	z_index = 10
	
func set_shopping_hand_mouse_entered() -> void:
	# 只有没执行拖拽和跟随逻辑时才触发
	if get_move_component().is_stop() == false:
		return 
	# 缩放动画
	if _hand_scale_tween and _hand_scale_tween.is_valid():
		_hand_scale_tween.kill()
	_hand_scale_tween = create_tween()
	_hand_scale_tween.tween_property(self, "scale", handMouseEnteredScale, 0.05)

	z_index = 10
	
func set_shopping_hand_mouse_exited() -> void:
	 # 缩放动画
	if _hand_scale_tween and _hand_scale_tween.is_valid():
		_hand_scale_tween.kill()
	_hand_scale_tween = create_tween()
	_hand_scale_tween.tween_property(self, "scale", Vector2.ONE, 0.05)

	#scale = Vector2(1.0, 1.0)
	z_index = 0
	
func set_player_hand_mouse_exited() -> void:
	 # 缩放动画
	if _hand_scale_tween and _hand_scale_tween.is_valid():
		_hand_scale_tween.kill()
	_hand_scale_tween = create_tween()
	_hand_scale_tween.tween_property(self, "scale", Vector2.ONE, 0.05)

	#scale = Vector2(1.0, 1.0)
	z_index = 0

func set_shopping_hand_mouse_down() -> void:
	scale = handButtonDownScale
	z_index = 10
	
func set_player_hand_mouse_down() -> void:
	scale = handButtonDownScale
	z_index = 10
	
func set_shopping_hand_mouse_up() -> void:
	scale = Vector2(1.0, 1.0)
	z_index = 0
	
func set_player_hand_mouse_up() -> void:
	scale = Vector2(1.0, 1.0)
	z_index = 0

@onready var shopButtonDownScale: Vector2 = Vector2(0.9, 0.9)

func set_shopping_shop_mouse_entered() -> void:
	pass
	
func set_shopping_shop_mouse_exited() -> void:
	pass

func set_shopping_shop_mouse_down() -> void:
	scale = shopButtonDownScale
	z_index = 10
	
func set_shopping_shop_mouse_up() -> void:
	scale = Vector2(1.0, 1.0)
	z_index = 0

func set_shopping_desk_mouse_down() -> void:
	z_index = 10
	
func set_shopping_desk_mouse_up() -> void:
	z_index = 0

func set_shopping_desk_mouse_entered() -> void:
	pass

func set_shopping_desk_mouse_exited() -> void:
	pass
