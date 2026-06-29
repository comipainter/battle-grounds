extends Control
class_name ShopCardComponent

@onready var shopContainer: ContainerComponent = $CardRegion/ShopCardRegion/HBoxContainer
@onready var deskContainer: ContainerComponent = $CardRegion/DeskCardRegion/HBoxContainer
@onready var handContainer: ContainerComponent = $CardRegion/HandCardRegion/HBoxContainer

@onready var shopCardFather: Control = $CardFather/Shop
@onready var noneCardFather: Control = $CardFather/None
@onready var deskCardFather: Control = $CardFather/Desk
@onready var handCardFather: Control = $CardFather/Hand
@onready var freeCardFather: Control = $CardFather/Free

@onready var shopInfo: ShopInfo = DataManager.get_shop_info()
@onready var gameInfo: GameInfo = DataManager.get_game_info()

# 信号列表
signal card_created(card: Card)

func init() -> void:
	shopContainer.set_sort_able(true)
	deskContainer.set_sort_able(true)
	handContainer.set_sort_able(false)
	shopInfo.desk_created.connect(_create_desk_card)
	shopInfo.hand_created.connect(_create_hand_card)
	shopInfo.shop_created.connect(_create_shop_card)
	shopInfo.free_created.connect(_create_free_card)
	shopInfo.moved_to_desk.connect(_move_card_to_desk)
	shopInfo.moved_to_hand.connect(_move_card_to_hand)
	shopInfo.moved_to_shop.connect(_move_card_to_shop)
	shopInfo.removed.connect(_remove_card)
	shopInfo.deleted.connect(_delete_card)

var able: bool = false
func set_able(_able):
	if able == _able:
		return
	if _able:
		self.visible = true
	else:
		self.visible = false
	able = _able

# 卡牌生产线
func _create_hand_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_hand_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

func _create_desk_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_desk_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card
	
func _create_shop_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_shop_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	## 创建商店卡牌时直接让卡牌到跟随点
	card.global_position = card.get_move_component().get_target().global_position
	card.use_info()
	card_created.emit(card)
	return card

func _create_free_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_free_card(CardUtils.create_card(info))
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

@export var hand_stiffness: float = 700.0
@export var hand_damping: float = 0.3
@export var hand_max_speed: float = 10000

@export var desk_stiffness: float = 3000
@export var desk_damping: float = 0.6
@export var desk_max_speed: float = 1000

@export var shop_stiffness: float = 6000
@export var shop_damping: float = 0.6
@export var shop_max_speed: float = 5000

func _add_hand_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(handCardFather)
	else:
		handCardFather.add_child(card)
	card.global_position = _position
	handContainer.add_card(card)
	card.get_move_component().set_stiffness(hand_stiffness)
	card.get_move_component().set_damping(hand_damping)
	card.get_move_component().set_max_speed(hand_max_speed)
	return card

func _add_desk_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(deskCardFather)
	else:
		deskCardFather.add_child(card)
	card.global_position = _position
	deskContainer.add_card(card)
	card.get_move_component().set_stiffness(desk_stiffness)
	card.get_move_component().set_damping(desk_damping)
	card.get_move_component().set_max_speed(desk_max_speed)
	return card

func _add_shop_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(shopCardFather)
	else:
		shopCardFather.add_child(card)
	card.global_position = _position
	shopContainer.add_card(card)
	card.get_move_component().set_stiffness(shop_stiffness)
	card.get_move_component().set_damping(shop_damping)
	card.get_move_component().set_max_speed(shop_max_speed)
	return card
	
func _add_free_card(card: Card) -> Card:
	freeCardFather.add_child(card)
	card.get_move_component().set_behavior_none()
	return card

# 卡牌移除线
func _remove_card(info: CardInfo) -> Card:
	var collection = get_card_collection()
	var filter = CardCollection.Filter.new().set_uniqueId(info.get_uniqueId())
	if collection.get_shop_collection().size() != 0:
		if collection.get_shop_collection().filter_by(filter).size() != 0:
			var card: Card = collection.get_shop_collection().filter_by(filter).get_array().get(0)
			_remove_shop_card(card)
			return card
	if collection.get_hand_collection().size() != 0:
		if collection.get_hand_collection().filter_by(filter).size() != 0:
			var card: Card = collection.get_hand_collection().filter_by(filter).get_array().get(0)
			_remove_hand_card(card)
			return card
	if collection.get_desk_collection().size() != 0:
		if collection.get_desk_collection().filter_by(filter).size() != 0:
			var card: Card = collection.get_desk_collection().filter_by(filter).get_array().get(0)
			_remove_desk_card(card)
			return card
	if collection.get_free_collection().size() != 0:
		if collection.get_free_collection().filter_by(filter).size() != 0:
			var card: Card = collection.get_free_collection().filter_by(filter).get_array().get(0)
			return card
	push_error("cannot find card to remove")
	return null
	
func _remove_shop_card(card: Card) -> void:
	shopContainer.remove_card(card)
	card.get_move_component().set_behavior_none()
	card.reparent(noneCardFather)

func _remove_desk_card(card: Card) -> void:
	deskContainer.remove_card(card)
	card.get_move_component().set_behavior_none()
	card.reparent(freeCardFather)

func _remove_hand_card(card: Card) -> void:
	handContainer.remove_card(card)
	card.get_move_component().set_behavior_none()
	card.reparent(freeCardFather)
		
# 卡牌删除线
func _delete_card(info: CardInfo) -> void:
	if able == false:
		return 
	var card: Card = _remove_card(info)
	if card != null:
		card.queue_free()

# 卡牌移动线
func _move_card_to_shop(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_shop_card(card, card.global_position)
	return null

func _move_card_to_desk(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_desk_card(card, card.global_position)
	return null

func _move_card_to_hand(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_hand_card(card, card.global_position)
	return null

# 信号总线
var _signal_able: bool = false
func is_signal_able() -> bool:
	return _signal_able
func set_signal_able(_able: bool) -> void:
	_signal_able = _able
	
func emit(_signal: Signal, card: Card) -> void:
	if is_signal_able():
		_signal.emit(card)

# 获取卡牌集合方法
func get_shop_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in shopCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_desk_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in deskCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_hand_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in handCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)
	
func get_free_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in freeCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)
	
func get_card_collection() -> ShopCardCollection:
	return ShopCardCollection.new().set_shop_collection(
		get_shop_card_collection()
	).set_desk_collection(
		get_desk_card_collection()
	).set_hand_collection(
		get_hand_card_collection()
	).set_free_collection(
		get_free_card_collection()
	)

func start() -> void:
	# 删除商店中的牌
	while shopCardFather.get_child_count() != 0:
		_delete_card(shopCardFather.get_child(0).get_info())
	# 加载商店信息中的卡牌
	#shopContainer.set_sort_able(false)
	for cardInfo in shopInfo.get_shop_info_collection().get_array():
		_create_shop_card(cardInfo, Vector2.ZERO)
	# 加载玩家手中新增的牌
	var handCardCollection: CardCollection = get_hand_card_collection()
	for cardInfo in shopInfo.get_hand_info_collection().get_array():
		var is_contain: bool = false
		for card in handCardCollection.get_array():
			if cardInfo.get_uniqueId() == card.get_info().get_uniqueId():
				is_contain = true
				break
		if is_contain == false:
			_create_hand_card(cardInfo, Vector2.ZERO)
	#shopContainer.set_sort_able(true)
	
func close() -> void:
	set_able(false)
