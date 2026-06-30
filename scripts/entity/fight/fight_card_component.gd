extends Control
class_name FightCardComponent

@onready var playerDeskContainer: ContainerComponent = $CardRegion/PlayerDeskCardRegion/HBoxContainer
@onready var playerHandContainer: ContainerComponent = $CardRegion/PlayerHandCardRegion/HBoxContainer
@onready var enemyDeskContainer: ContainerComponent = $CardRegion/EnemyDeskCardRegion/HBoxContainer
@onready var enemyHandContainer: ContainerComponent = $CardRegion/EnemyHandCardRegion/HBoxContainer

@onready var noneCardFather: Control = $CardFather/None
@onready var playerDeskCardFather: Control = $CardFather/PlayerDesk
@onready var playerHandCardFather: Control = $CardFather/PlayerHand
@onready var enemyDeskCardFather: Control = $CardFather/EnemyDesk
@onready var enemyHandCardFather: Control = $CardFather/EnemyHand
@onready var playerFreeCardFather: Control = $CardFather/PlayerFree
@onready var enemyFreeCardFather: Control = $CardFather/EnemyFree

@onready var fightInfo: FightInfo = DataManager.get_fight_info()
@onready var gameInfo: GameInfo = DataManager.get_game_info()

# 信号列表
signal card_created(card: Card)

func init() -> void:
	playerDeskContainer.set_sort_able(true)
	playerHandContainer.set_sort_able(false)
	enemyDeskContainer.set_sort_able(true)
	enemyHandContainer.set_sort_able(false)
	fightInfo.enemy_hand_created.connect(_create_enemy_hand_card)
	fightInfo.enemy_desk_created.connect(_create_enemy_desk_card)
	fightInfo.player_hand_created.connect(_create_player_hand_card)
	fightInfo.player_desk_created.connect(_create_player_desk_card)
	fightInfo.player_free_created.connect(_create_player_free_card)
	fightInfo.moved_to_enemy_desk.connect(_move_card_to_enemy_desk)
	fightInfo.moved_to_enemy_hand.connect(_move_card_to_enemy_hand)
	fightInfo.moved_to_player_desk.connect(_move_card_to_player_desk)
	fightInfo.moved_to_player_hand.connect(_move_card_to_player_hand)
	fightInfo.removed.connect(_remove_card)
	fightInfo.deleted.connect(_delete_card)

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
func _create_player_hand_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_player_hand_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

func _create_player_desk_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_player_desk_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

func _create_enemy_hand_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_enemy_hand_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

func _create_enemy_desk_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_enemy_desk_card(CardUtils.create_card(info), _position)
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

func _create_player_free_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_player_free_card(CardUtils.create_card(info))
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

func _create_enemy_free_card(info: CardInfo, _position: Vector2) -> Card:
	if able == false:
		return null
	var card: Card = _add_enemy_free_card(CardUtils.create_card(info))
	card.global_position = _position
	card.use_info()
	card_created.emit(card)
	return card

@export var hand_stiffness: float = 700.0
@export var hand_damping: float = 0.3

@export var desk_stiffness: float = 3000
@export var desk_damping: float = 0.6

func _add_player_hand_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(playerHandCardFather)
	else:
		playerHandCardFather.add_child(card)
	card.global_position = _position
	playerHandContainer.add_card(card)
	card.get_info().set_player_hand()
	card.get_move_component().set_stiffness(hand_stiffness)
	card.get_move_component().set_damping(hand_damping)
	return card

func _add_player_desk_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(playerDeskCardFather)
	else:
		playerDeskCardFather.add_child(card)
	card.global_position = _position
	playerDeskContainer.add_card(card)
	card.get_info().set_player_desk()
	card.get_move_component().set_stiffness(desk_stiffness)
	card.get_move_component().set_damping(desk_damping)
	return card

func _add_enemy_hand_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(enemyHandCardFather)
	else:
		enemyHandCardFather.add_child(card)
	card.global_position = _position
	enemyHandContainer.add_card(card)
	card.get_info().set_enemy_hand()
	card.get_move_component().set_stiffness(hand_stiffness)
	card.get_move_component().set_damping(hand_damping)
	return card

func _add_enemy_desk_card(card: Card, _position: Vector2) -> Card:
	if card.is_inside_tree():
		card.reparent(enemyDeskCardFather)
	else:
		enemyDeskCardFather.add_child(card)
	card.global_position = _position
	enemyDeskContainer.add_card(card)
	card.get_info().set_enemy_desk()
	card.get_move_component().set_stiffness(desk_stiffness)
	card.get_move_component().set_damping(desk_damping)
	return card

func _add_player_free_card(card: Card) -> Card:
	playerFreeCardFather.add_child(card)
	card.get_info().set_player_free()
	card.get_move_component().set_behavior_none()
	return card

func _add_enemy_free_card(card: Card) -> Card:
	enemyFreeCardFather.add_child(card)
	card.get_info().set_enemy_free()
	card.get_move_component().set_behavior_none()
	return card

# 卡牌移除线
func _remove_card(info: CardInfo) -> Card:
	var filter = CardCollection.Filter.new().set_uniqueId(info.get_uniqueId())
	# 如果该牌已经处于free状态，则不用移除
	if get_player_free_card_collection().size() != 0:
		if get_player_free_card_collection().filter_by(filter).size() != 0:
			return get_player_free_card_collection().filter_by(filter).get_array().get(0)
	if get_enemy_free_card_collection().size() != 0:
		if get_enemy_free_card_collection().filter_by(filter).size() != 0:
			return get_enemy_free_card_collection().filter_by(filter).get_array().get(0)
	if get_player_desk_card_collection().size() != 0:
		if get_player_desk_card_collection().filter_by(filter).size() != 0:
			var card: Card = get_player_desk_card_collection().filter_by(filter).get_array().get(0)
			_remove_player_desk_card(card)
			return card
	if get_player_hand_card_collection().size() != 0:
		if get_player_hand_card_collection().filter_by(filter).size() != 0:
			var card: Card = get_player_hand_card_collection().filter_by(filter).get_array().get(0)
			_remove_player_hand_card(card)
			return card
	if get_enemy_desk_card_collection().size() != 0:
		if get_enemy_desk_card_collection().filter_by(filter).size() != 0:
			var card: Card = get_enemy_desk_card_collection().filter_by(filter).get_array().get(0)
			_remove_enemy_desk_card(card)
			return card
	if get_enemy_hand_card_collection().size() != 0:
		if get_enemy_hand_card_collection().filter_by(filter).size() != 0:
			var card: Card = get_enemy_hand_card_collection().filter_by(filter).get_array().get(0)
			_remove_enemy_hand_card(card)
			return card
	push_error("cannot find card to remove")
	return null

func _remove_player_desk_card(card: Card) -> void:
	playerDeskContainer.remove_card(card)
	card.get_info().set_player_free()
	card.get_move_component().set_behavior_none()
	card.reparent(playerFreeCardFather)

func _remove_player_hand_card(card: Card) -> void:
	playerHandContainer.remove_card(card)
	card.get_info().set_player_free()
	card.get_move_component().set_behavior_none()
	card.reparent(playerFreeCardFather)

func _remove_enemy_desk_card(card: Card) -> void:
	enemyDeskContainer.remove_card(card)
	card.get_info().set_enemy_free()
	card.get_move_component().set_behavior_none()
	card.reparent(enemyFreeCardFather)

func _remove_enemy_hand_card(card: Card) -> void:
	enemyHandContainer.remove_card(card)
	card.get_info().set_enemy_free()
	card.get_move_component().set_behavior_none()
	card.reparent(enemyFreeCardFather)

# 卡牌删除线
func _delete_card(info: CardInfo) -> void:
	if able == false:
		return
	var card: Card = _remove_card(info)
	if card != null:
		card.free()

# 卡牌移动线
func _move_card_to_player_desk(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_player_desk_card(card, card.global_position)
	return null

func _move_card_to_player_hand(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_player_hand_card(card, card.global_position)
	return null

func _move_card_to_enemy_desk(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_enemy_desk_card(card, card.global_position)
	return null

func _move_card_to_enemy_hand(info: CardInfo) -> Card:
	if able == false:
		return null
	var card: Card = _remove_card(info)
	if card != null:
		return _add_enemy_hand_card(card, card.global_position)
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
func get_player_desk_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in playerDeskCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_player_hand_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in playerHandCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_player_free_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in playerFreeCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_enemy_desk_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in enemyDeskCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_enemy_hand_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in enemyHandCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func get_enemy_free_card_collection() -> CardCollection:
	var cards: Array[Card] = []
	for child in enemyFreeCardFather.get_children():
		if child is Card:
			cards.append(child)
	return CardCollection.new(cards)

func start() -> void:
	# 加载战斗信息中的卡牌
	load_enemy_desk_card_collection(fightInfo.get_enemy_desk_info_collection())
	load_enemy_hand_card_collection(fightInfo.get_enemy_hand_info_collection())
	load_player_desk_card_collection(fightInfo.get_player_desk_info_collection())
	load_player_hand_card_collection(fightInfo.get_player_hand_info_collection())
	
func load_enemy_desk_card_collection(_collection: CardInfoCollection) -> void:
	for i in range(_collection.get_array().size() - 1, -1, -1): # 使用倒序遍历
		var cardInfo = _collection.get_array()[i]
		_create_enemy_desk_card(cardInfo, Vector2.ZERO)

func load_enemy_hand_card_collection(_collection: CardInfoCollection) -> void:
	for i in range(_collection.get_array().size() - 1, -1, -1): # 使用倒序遍历
		var cardInfo = _collection.get_array()[i]
		_create_enemy_hand_card(cardInfo, Vector2.ZERO)

func load_player_desk_card_collection(_collection: CardInfoCollection) -> void:
	for i in range(_collection.get_array().size() - 1, -1, -1): # 使用倒序遍历
		var cardInfo = _collection.get_array()[i]
		_create_player_desk_card(cardInfo, Vector2.ZERO)

func load_player_hand_card_collection(_collection: CardInfoCollection) -> void:
	for i in range(_collection.get_array().size() - 1, -1, -1): # 使用倒序遍历
		var cardInfo = _collection.get_array()[i]
		_create_player_hand_card(cardInfo, Vector2.ZERO)

func delete_all_card() -> void:
	while playerHandCardFather.get_child_count() != 0:
		_delete_card(playerHandCardFather.get_child(0).get_info())
	while playerDeskCardFather.get_child_count() != 0:
		_delete_card(playerDeskCardFather.get_child(0).get_info())
	while playerFreeCardFather.get_child_count() != 0:
		_delete_card(playerFreeCardFather.get_child(0).get_info())
	while enemyHandCardFather.get_child_count() != 0:
		_delete_card(enemyHandCardFather.get_child(0).get_info())
	while enemyDeskCardFather.get_child_count() != 0:
		_delete_card(enemyDeskCardFather.get_child(0).get_info())
	while enemyFreeCardFather.get_child_count() != 0:
		_delete_card(enemyFreeCardFather.get_child(0).get_info())
		
