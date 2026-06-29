extends Node
class_name CardComponent

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
func create_player_hand_card(info: CardInfo, position: Vector2) -> Card:
	var card: Card = _add_player_hand_card(CardUtils.create_card(info))
	card.global_position = position
	card.use_info()
	card_created.emit(card)
	return card

func create_player_desk_card(info: CardInfo, position: Vector2) -> Card:
	var card: Card = _add_player_desk_card(CardUtils.create_card(info))
	card.global_position = position
	card.use_info()
	card_created.emit(card)
	return card
	
func create_enemy_hand_card(info: CardInfo, position: Vector2) -> Card:
	var card: Card = _add_enemy_hand_card(CardUtils.create_card(info))
	card.global_position = position
	card.use_info()
	card_created.emit(card)
	return card

func create_enemy_desk_card(info: CardInfo, position: Vector2) -> Card:
	var card: Card = _add_enemy_desk_card(CardUtils.create_card(info))
	card.global_position = position
	card.use_info()
	card_created.emit(card)
	return card

func create_player_free_card(info: CardInfo, position: Vector2) -> Card:
	var card: Card = _add_player_free_card(CardUtils.create_card(info))
	card.global_position = position
	card.use_info()
	card_created.emit(card)
	return card

func create_enemy_free_card(info: CardInfo, position: Vector2) -> Card:
	var card: Card = _add_enemy_free_card(CardUtils.create_card(info))
	card.global_position = position
	card.use_info()
	card_created.emit(card)
	return card

@export var hand_stiffness: float = 700.0
@export var hand_damping: float = 0.3

@export var desk_stiffness: float = 3000
@export var desk_damping: float = 0.6

@export var shop_stiffness: float = 6000
@export var shop_damping: float = 0.6

func _add_player_hand_card(card: Card) -> Card:
	if card.is_inside_tree():
		card.reparent(playerHandCardFather)
	else:
		playerHandCardFather.add_child(card)
	playerHandContainer.add_card(card)
	card.get_info().set_player_hand()
	if gameInfo.is_fighting():
		fightInfo.get_player_hand_info_collection().add(card.get_info())
	else:
		push_error("no matching collection on player_hand_info")
	card.get_move_component().set_stiffness(hand_stiffness)
	card.get_move_component().set_damping(hand_damping)
	return card

func _add_player_desk_card(card: Card) -> Card:
	if card.is_inside_tree():
		card.reparent(playerDeskCardFather)
	else:
		playerDeskCardFather.add_child(card)
	playerDeskContainer.add_card(card)
	card.get_info().set_player_desk()
	if gameInfo.is_fighting():
		fightInfo.get_player_desk_info_collection().add(card.get_info())
	else:
		push_error("no matching collection on player_desk_info")
	card.get_move_component().set_stiffness(desk_stiffness)
	card.get_move_component().set_damping(desk_damping)
	return card

func _add_enemy_hand_card(card: Card) -> Card:
	if card.is_inside_tree():
		card.reparent(enemyHandCardFather)
	else:
		enemyHandCardFather.add_child(card)
	enemyHandContainer.add_card(card)
	card.get_info().set_enemy_hand()
	if gameInfo.is_fighting():
		fightInfo.get_enemy_hand_info_collection().add(card.get_info())
	else:
		push_error("no matching collection on enemy_hand_info")
	card.get_move_component().set_stiffness(hand_stiffness)
	card.get_move_component().set_damping(hand_damping)
	return card

func _add_enemy_desk_card(card: Card) -> Card:
	if card.is_inside_tree():
		card.reparent(enemyDeskCardFather)
	else:
		enemyDeskCardFather.add_child(card)
	enemyDeskContainer.add_card(card)
	card.get_info().set_enemy_desk()
	if gameInfo.is_fighting():
		fightInfo.get_enemy_desk_info_collection().add(card.get_info())
	else:
		push_error("no matching collection on enemy_desk_info")
	card.get_move_component().set_stiffness(desk_stiffness)
	card.get_move_component().set_damping(desk_damping)
	return card
	
func _add_player_free_card(card: Card) -> Card:
	playerFreeCardFather.add_child(card)
	card.get_info().set_player_free()
	return card
	
func _add_enemy_free_card(card: Card) -> Card:
	enemyFreeCardFather.add_child(card)
	card.get_info().set_enemy_free()
	return card

# 卡牌移除线
func remove_card(card: Card) -> void:
	var info: CardInfo = card.get_info()
	if info.is_shopping_shop():
		_remove_shop_card(card)
	if info.is_player_desk():
		_remove_player_desk_card(card)
	elif info.is_player_hand():
		_remove_player_hand_card(card)
	elif info.is_enemy_desk():
		_remove_enemy_desk_card(card)
	elif info.is_enemy_hand():
		_remove_enemy_hand_card(card)
		
func _remove_shop_card(card: Card) -> void:
	playerDeskContainer.remove_card(card)
	card.get_info().set_player_free()
	card.reparent(playerFreeCardFather)
	if gameInfo.is_fighting():
		fightInfo.get_player_desk_info_collection().erase(card.get_info())
	else:
		push_error("no matching collection on player_desk_info")
		
func _remove_player_desk_card(card: Card) -> void:
	playerDeskContainer.remove_card(card)
	card.get_info().set_player_free()
	card.reparent(playerFreeCardFather)
	if gameInfo.is_fighting():
		fightInfo.get_player_desk_info_collection().erase(card.get_info())
	else:
		push_error("no matching collection on player_desk_info")

func _remove_player_hand_card(card: Card) -> void:
	playerHandContainer.remove_card(card)
	card.get_info().set_player_free()
	card.reparent(playerFreeCardFather)
	if gameInfo.is_fighting():
		fightInfo.get_player_hand_info_collection().erase(card.get_info())
	else:
		push_error("no matching collection on player_hand_info")

func _remove_enemy_desk_card(card: Card) -> void:
	enemyDeskContainer.remove_card(card)
	card.get_info().set_enemy_free()
	card.reparent(enemyFreeCardFather)
	if gameInfo.is_fighting():
		fightInfo.get_enemy_desk_info_collection().erase(card.get_info())
	else:
		push_error("no matching collection on enemy_desk_info")

func _remove_enemy_hand_card(card: Card) -> void:
	enemyHandContainer.remove_card(card)
	card.get_info().set_enemy_free()
	card.reparent(enemyFreeCardFather)
	if gameInfo.is_fighting():
		fightInfo.get_enemy_hand_info_collection().erase(card.get_info())
	else:
		push_error("no matching collection on enemy_hand_info")

# 卡牌删除线
func delete_card(card: Card) -> void:
	remove_card(card)
	card.queue_free()

# 卡牌移动线
func move_card_to_player_desk(card: Card) -> Card:
	remove_card(card)
	return _add_player_desk_card(card)

func move_card_to_player_hand(card: Card) -> Card:
	remove_card(card)
	return _add_player_hand_card(card)

func move_card_to_enemy_desk(card: Card) -> Card:
	remove_card(card)
	return _add_enemy_desk_card(card)
	
func move_card_to_enemy_hand(card: Card) -> Card:
	remove_card(card)
	return _add_enemy_hand_card(card)

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

# 批量删除方法不释放信号
func delete_all_player_hand_card() -> void:
	set_signal_able(false)
	while playerHandCardFather.get_child_count() != 0:
		delete_card(playerHandCardFather.get_child(0))
	set_signal_able(true)
		
func delete_all_player_desk_card() -> void:
	set_signal_able(false)
	while playerDeskCardFather.get_child_count() != 0:
		delete_card(playerDeskCardFather.get_child(0))
	set_signal_able(true)
		
func delete_all_enemy_hand_card() -> void:
	set_signal_able(false)
	while enemyHandCardFather.get_child_count() != 0:
		delete_card(enemyHandCardFather.get_child(0))
	set_signal_able(true)
		
func delete_all_enemy_desk_card() -> void:
	set_signal_able(false)
	while enemyDeskCardFather.get_child_count() != 0:
		delete_card(enemyDeskCardFather.get_child(0))
	set_signal_able(true)

# 加载方法不释放信号
func load_player_desk_collection(_collection: CardInfoCollection) -> void:
	set_signal_able(false)
	playerDeskContainer.set_sort_able(false)
	for cardInfo in _collection.get_array():
		create_player_desk_card(cardInfo, Vector2(0, 0))
	playerDeskContainer.set_sort_able(true)
	set_signal_able(true)

func load_player_hand_collection(_collection: CardInfoCollection) -> void:
	set_signal_able(false)
	playerHandContainer.set_sort_able(false)
	for cardInfo in _collection.get_array():
		create_player_hand_card(cardInfo, Vector2(0, 0))
	playerHandContainer.set_sort_able(true)
	set_signal_able(true)

func load_enemy_desk_collection(_collection: CardInfoCollection) -> void:
	set_signal_able(false)
	enemyDeskContainer.set_sort_able(false)
	for cardInfo in _collection.get_array():
		create_enemy_desk_card(cardInfo, Vector2(0, 0))
	enemyDeskContainer.set_sort_able(true)
	set_signal_able(true)

func load_enemy_hand_collection(_collection: CardInfoCollection) -> void:
	set_signal_able(false)
	enemyHandContainer.set_sort_able(false)
	for cardInfo in _collection.get_array():
		create_enemy_hand_card(cardInfo, Vector2(0, 0))
	enemyHandContainer.set_sort_able(true)
	set_signal_able(true)
