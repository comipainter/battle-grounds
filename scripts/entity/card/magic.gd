extends Card
class_name Magic

var magicInfo: MagicInfo = MagicInfo.new()
func get_info() -> MagicInfo:
	return magicInfo
func set_info(_info: CardInfo) -> void:
	magicInfo = _info
func use_info() -> void:
	if get_info().is_shopping_shop():
		shopComponent.use_info()
	elif get_info().is_hand():
		handComponent.use_info()

# 信号
signal used(magic: Magic)
signal deleted(magic: Magic)

@onready var shopComponent: MagicShopInfoComponent = $MagicInfo/SubViewportContainer/SubViewport/ShopMagicInfo
@onready var handComponent: MagicHandInfoComponent = $MagicInfo/SubViewportContainer/SubViewport/HandMagicInfo

@onready var shadowComponent: CardShadowComponent = $CardShadowComponent

@onready var vfxComponent: MagicVfxComponent = $MagicVfx

@onready var viewportComponent: MagicViewportComponent = $Animation/Sprite2D

func get_vfx_component() -> MagicVfxComponent:
	return vfxComponent
	
# 启动后下发节点信息到每个component
func _distribute_self() -> void:
	shopComponent.set_magic(self)
	handComponent.set_magic(self)
	viewportComponent.set_magic(self)

func _ready() -> void:
	super._ready()
	_distribute_self()

func _process(delta: float) -> void:
	# 基于当前的归属自动调整随从信息展示格式
	if get_info().is_hand():
		handComponent.set_able(true)
		shopComponent.set_able(false)
		shadowComponent.set_shadow_sprite(
			ImageAssets.MagicHandShadow,
			ImageAssets.MagicHandShadow_Scale
		)
	elif get_info().is_shopping_shop():
		handComponent.set_able(false)
		shopComponent.set_able(true)
		shadowComponent.set_shadow_sprite(
			ImageAssets.MagicShopShadow,
			ImageAssets.MagicShopShadow_Scale
		)
		
# 动效设置
func set_shopping_shop_mouse_entered() -> void:
	if DataManager.get_shop_info().get_coin() >= get_info().get_cost():
		get_vfx_component().set_shop_vfx_able(true)
	super.set_shopping_shop_mouse_entered()

func set_shopping_shop_mouse_exited() -> void:
	get_vfx_component().set_shop_vfx_able(false)
	super.set_shopping_shop_mouse_exited()

func set_shopping_shop_mouse_down() -> void:
	if DataManager.get_shop_info().get_coin() >= get_info().get_cost():
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
	if _animation is not MagicAnimation:
		push_error("add Not MagicAnimation on Magic")
	else:
		super.add_animation(_animation)
