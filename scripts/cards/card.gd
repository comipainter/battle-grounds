extends Control
class_name Card

# 卡牌信息
var cardInfo: CardInfo
func set_info(info: CardInfo) -> void:
	self.cardInfo = info
func get_info() -> CardInfo:
	return self.cardInfo
func use_info() -> void:
	pass
func get_cardName() -> String:
	return cardInfo.name
func get_id() -> int:
	return cardInfo.id
func get_level() -> int:
	return cardInfo.level

# 三连标记：即将被三连的随从不能被出售或者上场
var tripleLock: bool = false
var tripleReady: bool = false
func set_tripleLock(lock: bool) -> void:
	tripleLock = lock
func is_tripleLock() -> bool:
	return tripleLock
func set_tripleReady(isReady: bool) -> void:
	tripleReady = isReady
func is_tripleReady() -> bool:
	return tripleReady

# 悬停相关
var originCardNode: Control
func hover() -> void:
	pass
func exit_hover() -> void:
	pass

# 动画相关
var animationQueueManager: AnimationQueueManager = AnimationQueueManager.new()
func add_animation(animation: CardAnimation) -> void:
	animationQueueManager.add_animation(animation)
func is_idle() -> bool:
	return (!is_moving() and animationQueueManager.is_idle())
func ableOperation(able: bool) -> void:
	if able == false:
		drag(false)
	else:
		drag(true)

# 归属相关
enum BELONG_SHOP{NONE, SHOP, DESK, HAND}
var belongShop: BELONG_SHOP = BELONG_SHOP.NONE
func is_belong_shopScene() -> bool:
	return !(belongShop == BELONG_SHOP.NONE)
func is_belong_shop() -> bool:
	return belongShop == BELONG_SHOP.SHOP
func is_belong_desk() -> bool:
	return belongShop == BELONG_SHOP.DESK
func is_belong_hand() -> bool:
	return belongShop == BELONG_SHOP.HAND
func set_belong_none() -> void:
	belongShop = BELONG_SHOP.NONE
func set_belong_shop() -> void:
	belongShop = BELONG_SHOP.SHOP
func set_belong_desk() -> void:
	belongShop = BELONG_SHOP.DESK
func set_belong_hand() -> void:
	belongShop = BELONG_SHOP.HAND

enum BELONG_FIGHT{NONE, ENEMY_DESK, ENEMY_HAND, PLAYER_DESK, PLYAER_HAND}
var belongfight: BELONG_FIGHT = BELONG_FIGHT.NONE
func is_belong_fightScene() -> bool:
	return !(belongfight == BELONG_FIGHT.NONE)
func is_belong_player() -> bool:
	return (belongfight == BELONG_FIGHT.PLAYER_DESK) or \
	 (belongfight == BELONG_FIGHT.PLYAER_HAND)
func is_belong_enemy() -> bool:
	return (belongfight == BELONG_FIGHT.ENEMY_DESK) or \
	 (belongfight == BELONG_FIGHT.ENEMY_HAND)
func is_belong_fight_desk() -> bool:
	return (belongfight == BELONG_FIGHT.PLAYER_DESK) or \
	 (belongfight == BELONG_FIGHT.ENEMY_DESK)
func is_belong_fight_hand() -> bool:
	return (belongfight == BELONG_FIGHT.PLYAER_HAND) or \
	 (belongfight == BELONG_FIGHT.ENEMY_HAND)
func set_belong_fight_none() -> void:
	belongfight = BELONG_FIGHT.NONE
func set_belong_enemy_desk() -> void:
	belongfight = BELONG_FIGHT.ENEMY_DESK
func set_belong_enemy_hand() -> void:
	belongfight = BELONG_FIGHT.ENEMY_HAND
func set_belong_player_desk() -> void:
	belongfight = BELONG_FIGHT.PLAYER_DESK
func set_belong_player_hand() -> void:
	belongfight = BELONG_FIGHT.PLYAER_HAND

# 运动控制
var followNode: Control
enum MOVE{FOLLOW, DRAG}
var move: MOVE = MOVE.FOLLOW
var canDarg: bool = true
var canFollow: bool = true
var following: bool = true
func drag(able: bool) -> void:
	canDarg = able
func follow(able: bool) -> void:
	canFollow = able
func set_followNode(node: Control) -> void:
	followNode = node
func get_followNode() -> Control:
	return followNode
func is_drag() -> bool:
	return move == MOVE.DRAG
func is_follow() -> bool:
	return move == MOVE.FOLLOW
func is_moving() -> bool:
	return (following or is_drag())

# 附着参数
var velocity = Vector2.ZERO
var damping = 0.35
var stiffness = 500

# 鼠标悬停判断
var hover_start_time = 0
const HOVER_DURATION_MS = 500
var is_entered: bool
var is_hovering: bool

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	# 启用动画
	animationQueueManager.play()
	# 悬停判断逻辑
	if is_entered and not is_hovering:
		var elapsed = Time.get_ticks_msec() - hover_start_time
		if elapsed >= HOVER_DURATION_MS:
			is_hovering = true
			self.hover()
	match move:
		MOVE.FOLLOW:
			if followNode != null:
				if canFollow == true:
					var target_position = followNode.global_position
					var displacement = target_position - global_position
					var distance = displacement.length()
					if distance < 2.0:  # 已经足够达到目标，调整为idle状态
						global_position = target_position
						velocity = Vector2.ZERO
						following = false
					else:
						var force = displacement * stiffness
						velocity += force * delta
						velocity *= (1.0 - damping)
						global_position += velocity * delta
						following = true
		MOVE.DRAG:
			if canDarg == true:
				var target_position = get_global_mouse_position()
				global_position = global_position.lerp(target_position, 0.4)
				following = false
	pass

func _button_down() -> void:
	if canDarg == true:
		move = MOVE.DRAG
	if self.is_hovering == true:
		self.exit_hover()
	self.is_entered = false
	self.is_hovering = false

func _button_up() -> void:
	move = MOVE.FOLLOW
	if self.is_belong_shopScene():
		if GameManager.shopScene.is_in_buy_region(self) and is_belong_shop():
				GameManager.shopScene.buy(self)
		elif GameManager.shopScene.is_in_desk_region(self) and is_belong_hand():
			if is_tripleLock() == false:
				GameManager.shopScene.use(self)
		elif GameManager.shopScene.is_in_sell_region(self) and is_belong_desk():
			if is_minion():
				if is_tripleLock() == false:
					GameManager.shopScene.sell(self)

func _mouse_entered() -> void:
	self.is_entered = true
	hover_start_time = Time.get_ticks_msec()
	self.is_hovering = false

func _mouse_exited() -> void:
	if self.is_hovering == true:
		self.exit_hover()
	self.is_entered = false
	self.is_hovering = false

# 卡牌种类
var cardType: GameManager.CARDTYPE
func is_magic() -> bool:
	return cardType == GameManager.CARDTYPE.MAGIC
func is_minion() -> bool:
	return cardType == GameManager.CARDTYPE.MINION
