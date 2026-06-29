extends Card
class_name Minion

@onready var shopMinionComponent: MinionShopInfoComponent = $MinionInfo/ShopMinionInfo
@onready var deskMinionComponent: MinionDeskInfoComponent = $MinionInfo/DeskMinionInfo
@onready var handMinionComponent: MinionHandInfoComponent = $MinionInfo/HandMinionInfo
@onready var shadowComponent: CardShadowComponent = $CardShadowComponent
@onready var vfxComponent: MinionVfxComponent = $MinionVfx
@onready var minionFather: Control = $MinionFather
@onready var displayComponent: MinionDisplayComponent = $MinionDisplay

func get_shop_info_component() -> MinionShopInfoComponent:
	return shopMinionComponent
func get_desk_info_component() -> MinionDeskInfoComponent:
	return deskMinionComponent
func get_hand_info_component() -> MinionHandInfoComponent:
	return handMinionComponent
func get_vfx_component() -> MinionVfxComponent:
	return vfxComponent

# 启动后下发节点信息到每个component
func _distribute_self() -> void:
	deskMinionComponent.set_minion(self)
	handMinionComponent.set_minion(self)
	shopMinionComponent.set_minion(self)
	displayComponent.set_minion(self)

# 随从信号
signal attack_befored(attackMinion: Minion, behitMinion: Minion)
signal attack_inged(attackMinion: Minion, behitMinion: Minion)
signal attack_aftered(attackMinion: Minion, behitMinion: Minion)
signal sold(minion: Minion)
signal dead_after(minion: Minion)
signal processed(minion: Minion, delta: float)

var minionInfo: MinionInfo = MinionInfo.new()
func get_info() -> MinionInfo:
	return minionInfo
func set_info(_info: CardInfo) -> void:
	minionInfo = _info
func use_info() -> void:
	if get_info().is_minion():
		if get_info().is_hand():
			handMinionComponent.use_info()
		elif get_info().is_desk():
			deskMinionComponent.use_info()
		elif get_info().is_shopping():
			shopMinionComponent.use_info()
	else:
		push_error("use not MinionInfo on minion")
		
func _ready() -> void:
	super._ready()
	_distribute_self()
	deskMinionComponent.set_able(false)
	handMinionComponent.set_able(false)
	shopMinionComponent.set_able(false)

func _process(delta: float) -> void:
	# 基于当前的归属自动调整随从信息展示格式
	if get_info().is_hand():
		deskMinionComponent.set_able(false)
		handMinionComponent.set_able(true)
		shopMinionComponent.set_able(false)
		shadowComponent.set_shadow_sprite(
			ImageAssets.MinionHandShadow,
			ImageAssets.MinionHandShadow_Scale
		)
	elif get_info().is_desk():
		deskMinionComponent.set_able(true)
		handMinionComponent.set_able(false)
		shopMinionComponent.set_able(false)
		shadowComponent.set_shadow_sprite(
			ImageAssets.MinionDeskShadow,
			ImageAssets.MinionDeskShadow_Scale
		)
	elif get_info().is_shopping_shop():
		deskMinionComponent.set_able(false)
		handMinionComponent.set_able(false)
		shopMinionComponent.set_able(true)
		shadowComponent.set_shadow_sprite(
			ImageAssets.MinionShopShadow,
			ImageAssets.MinionShopShadow_Scale
		)
	processed.emit(self, delta)
	
# 动效设置
func set_shopping_shop_mouse_entered() -> void:
	if DataManager.get_shop_info().get_coin() >= DataManager.get_shop_info().get_buy_minion_cost():
		get_vfx_component().set_shop_vfx_able(true)
	super.set_shopping_shop_mouse_entered()

func set_shopping_shop_mouse_exited() -> void:
	get_vfx_component().set_shop_vfx_able(false)
	super.set_shopping_shop_mouse_exited()

func set_shopping_shop_mouse_down() -> void:
	if DataManager.get_shop_info().get_coin() >= DataManager.get_shop_info().get_buy_minion_cost():
		get_vfx_component().set_shop_vfx_able(true)
	super.set_shopping_shop_mouse_down()

func set_shopping_shop_mouse_up() -> void:
	get_vfx_component().set_shop_vfx_able(false)
	super.set_shopping_shop_mouse_up()

func set_shopping_hand_mouse_entered() -> void:
	get_vfx_component().set_hand_vfx_able(true)
	super.set_shopping_hand_mouse_entered()
	
func set_shopping_hand_mouse_exited() -> void:
	get_vfx_component().set_hand_vfx_able(false)
	super.set_shopping_hand_mouse_exited()
	
func set_shopping_hand_mouse_down() -> void:
	get_vfx_component().set_hand_vfx_able(true)
	super.set_shopping_hand_mouse_down()
	
func set_shopping_hand_mouse_up() -> void:
	get_vfx_component().set_hand_vfx_able(false)
	super.set_shopping_hand_mouse_up()

func set_shopping_desk_mouse_entered() -> void:
	get_vfx_component().set_desk_vfx_able(true)
	super.set_shopping_desk_mouse_entered()

func set_shopping_desk_mouse_exited() -> void:
	get_vfx_component().set_desk_vfx_able(false)
	super.set_shopping_desk_mouse_exited()

func set_shopping_desk_mouse_down() -> void:
	get_vfx_component().set_desk_vfx_able(true)
	super.set_shopping_desk_mouse_down()

func set_shopping_desk_mouse_up() -> void:
	get_vfx_component().set_desk_vfx_able(false)
	super.set_shopping_desk_mouse_up()
	
func set_player_hand_mouse_entered() -> void:
	get_vfx_component().set_hand_vfx_able(true)
	super.set_player_hand_mouse_entered()
	
func set_player_hand_mouse_exited() -> void:
	get_vfx_component().set_hand_vfx_able(false)
	super.set_player_hand_mouse_exited()
	
func set_player_hand_mouse_down() -> void:
	get_vfx_component().set_hand_vfx_able(true)
	super.set_player_hand_mouse_down()
	
func set_player_hand_mouse_up() -> void:
	get_vfx_component().set_hand_vfx_able(false)
	super.set_player_hand_mouse_up()

# 动画设置
func add_animation(_animation: BaseAnimation) -> void:
	if _animation == null:
		return
	elif _animation is not MinionAnimation:
		push_error("add Not MinionAnimation on Minion")
	else:
		super.add_animation(_animation)
	
# 三连锁
var tripleLock: bool = false
func set_triple_lock(_lock) -> void:
	tripleLock = _lock
func get_triple_lock() -> bool:
	return tripleLock

func is_idle() -> bool:
	return super.is_idle() and\
	get_desk_info_component().get_stats_component().is_idle() and\
	get_hand_info_component().get_stats_component().is_idle() and\
	get_base_minion_collection().is_idle()

var father: Minion = null
func get_father() -> Minion:
	return father
func add_base_minion(_minion: Minion) -> void:
	if _minion.is_inside_tree():
		if minionFather != _minion.get_parent():
			minionFather.reparent(_minion)
	else:
		push_error("base minion not inside tree")
	_minion.get_desk_info_component().visible = false
	_minion.get_hand_info_component().visible = false
	_minion.get_shop_info_component().visible = false
	_minion.get_vfx_component().visible = false
	_minion.shadowComponent.visible = false
	_minion.get_move_component().disable_drag()
	_minion.get_move_component().disable_follow()
	_minion.interactionComponent.visible = false
	_minion.position = Vector2.ZERO
	_minion.father = self

func get_base_minion_collection() -> MinionCollection:
	var collection: MinionCollection = MinionCollection.new()
	for _minion in self.minionFather.get_children():
		collection.add(_minion)
	return collection
	
