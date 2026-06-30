extends Resource
class_name ShopInfo

func copy() -> ShopInfo:
	var _info: ShopInfo = duplicate(true)
	_info.set_hand_info_collection(
		get_hand_info_collection().copy()
	)
	_info.set_desk_info_collection(
		get_desk_info_collection().copy()
	)
	_info.set_shop_info_collection(
		get_shop_info_collection().copy()
	)
	return _info

# 运行信息
@export var level: int = ShopConstant.get_init_level()

signal level_changed
func set_level(_level: int) -> void:
	level = _level
	level_changed.emit()
func get_level() -> int:
	return level

@export var upgradeCost: Array[int] = ShopConstant.get_upgrade_cost().duplicate(true)

func set_upgrade_cost(_cost: int, _level: int) -> void:
	upgradeCost[_level] = _cost
func get_upgrade_cost() -> int:
	if level == ShopConstant.get_max_level():
		return -1
	return upgradeCost[level + 1]

@export var shopCollection: CardInfoCollection = CardInfoCollection.new()
func set_shop_info_collection(_collection: CardInfoCollection) -> void:
	shopCollection = _collection
func get_shop_info_collection() -> CardInfoCollection:
	return shopCollection

@export var handCollection: CardInfoCollection = CardInfoCollection.new()
func set_hand_info_collection(_collection: CardInfoCollection) -> void:
	handCollection = _collection
func get_hand_info_collection() -> CardInfoCollection:
	return handCollection

@export var deskCollection: CardInfoCollection = CardInfoCollection.new()
func set_desk_info_collection(_collection: CardInfoCollection) -> void:
	deskCollection = _collection
func get_desk_info_collection() -> CardInfoCollection:
	return deskCollection

@export var freeCollection: CardInfoCollection = CardInfoCollection.new()
func set_free_info_collection(_collection: CardInfoCollection) -> void:
	freeCollection = _collection
func get_free_info_collection() -> CardInfoCollection:
	return freeCollection
	
signal shop_created
func create_shop_card_info(info: CardInfo, position: Vector2) -> void:
	_add_to_shop(info)
	shop_created.emit(info, position)
signal hand_created
func create_hand_card_info(info: CardInfo, position: Vector2) -> void:
	if DataManager.get_player_info().get_hand_card_num() == handCollection.size():
		return
	_add_to_hand(info)
	hand_created.emit(info, position)
signal desk_created
func create_desk_card_info(info: CardInfo, position: Vector2) -> void:
	if DataManager.get_player_info().get_desk_card_num() == deskCollection.size():
		return
	_add_to_desk(info)
	desk_created.emit(info, position)
signal free_created
func create_free_card_info(info: CardInfo, position: Vector2) -> void:
	_add_to_free(info)
	free_created.emit(info, position)
	
signal shop_removed
func _remove_shop_card_info(info: CardInfo) -> void:
	info.set_shopping_free()
	shopCollection.erase(info)
	_add_to_free(info)
	shop_removed.emit(info)
signal hand_removed
func _remove_hand_card_info(info: CardInfo) -> void:
	handCollection.erase(info)
	info.set_shopping_free()
	_add_to_free(info)
	hand_removed.emit(info)
signal desk_removed
func _remove_desk_card_info(info: CardInfo) -> void:
	deskCollection.erase(info)
	info.set_shopping_free()
	_add_to_free(info)
	desk_removed.emit(info)
	
signal shop_added
func _add_to_shop(info: CardInfo) -> void:
	shopCollection.add(info)
	info.set_shopping_shop()
	shop_added.emit(info)
signal hand_added
func _add_to_hand(info: CardInfo) -> void:
	if DataManager.get_player_info().get_hand_card_num() == handCollection.size():
		return
	handCollection.add(info)
	info.set_shopping_hand()
	hand_added.emit(info)
signal desk_added
func _add_to_desk(info: CardInfo) -> void:
	if DataManager.get_player_info().get_desk_card_num() == deskCollection.size():
		return
	deskCollection.add(info)
	info.set_shopping_desk()
	desk_added.emit(info)
signal free_added
func _add_to_free(info: CardInfo) -> void:
	freeCollection.add(info)
	info.set_shopping_free()
	free_added.emit(info)
	
signal removed
func remove_card_info(info: CardInfo) -> void:
	_remove_card_info(info)
	removed.emit(info)

func _remove_card_info(info: CardInfo) -> void:
	if info.is_shopping_desk():
		_remove_desk_card_info(info)
	elif info.is_shopping_hand():
		_remove_hand_card_info(info)
	elif info.is_shopping_shop():
		_remove_shop_card_info(info)

signal moved_to_shop
func move_card_to_shop(info: CardInfo) -> void:
	_remove_card_info(info)
	freeCollection.erase(info)
	_add_to_shop(info)
	moved_to_shop.emit(info)
signal moved_to_desk
func move_card_to_desk(info: CardInfo) -> void:
	if DataManager.get_player_info().get_desk_card_num() == deskCollection.size():
		return
	_remove_card_info(info)
	freeCollection.erase(info)
	_add_to_desk(info)
	moved_to_desk.emit(info)
signal moved_to_hand
func move_card_to_hand(info: CardInfo) -> void:
	if DataManager.get_player_info().get_hand_card_num() == handCollection.size():
		return
	_remove_card_info(info)
	freeCollection.erase(info)
	_add_to_hand(info)
	moved_to_hand.emit(info)
	
signal deleted
func delete_card_info(info: CardInfo) -> void:
	_remove_card_info(info)
	freeCollection.erase(info)
	deleted.emit(info)
	
func delete_all_shop_card() -> void:
	while get_shop_info_collection().size() != 0:
		delete_card_info(get_shop_info_collection().get_array().get(0))

@export var coin: int = ShopConstant.get_init_coin()

func set_coin(_coin: int) -> void:
	coin = _coin
func get_coin() -> int:
	return coin
signal coin_added(_added_coin)
func add_coin(_added_coin: int) -> void:
	coin += _added_coin
	coin_added.emit(_added_coin)
signal coin_subed(_subed_coin)
func sub_coin(_subed_coin: int) -> void:
	coin -= _subed_coin
	coin_subed.emit(_subed_coin)
	
@export var coinLimit: int = ShopConstant.get_coin_limit()

func set_coin_limit(_coinLimit: int) -> void:
	coinLimit = _coinLimit
func get_coin_limit() -> int:
	return coinLimit
	
@export var coinMaxLimit: int = ShopConstant.get_coin_max_limit()

func set_coin_max_limit(_coinMaxLimit: int) -> void:
	coinMaxLimit = _coinMaxLimit
func get_coin_max_limit() -> int:
	return coinMaxLimit

@export var currBuyMinionCost: int = ShopConstant.get_buy_minion_cost()

func set_buy_minion_cost(_cost: int) -> void:
	currBuyMinionCost = _cost
func get_buy_minion_cost() -> int:
	return currBuyMinionCost

@export var currFreshCost: int = ShopConstant.get_fresh_cost()

func set_fresh_cost(_cost: int) -> void:
	currFreshCost = _cost
	fresh_cost_changed.emit()
signal fresh_cost_changed
func get_fresh_cost() -> int:
	return currFreshCost
	
@export var currTime: int = ShopConstant.get_init_time()
func set_time(_time: int) -> void:
	currTime = _time
func get_time() -> int:
	return currTime

@export var minionNum: int = ShopConstant.get_minion_num().get(1)
func set_minion_num(_num: int) -> void:
	minionNum = _num
func get_minion_num() -> int:
	return ShopConstant.get_minion_num().get(get_level())
	
@export var magicNum: int = ShopConstant.get_magic_num()
func set_magic_num(_num: int) -> void:
	magicNum = _num
func get_magic_num() -> int:
	return magicNum
	
@export var maxLevel: int = ShopConstant.get_max_level()
func set_max_level(_level: int) -> void:
	maxLevel = _level
func get_max_level() -> int:
	return maxLevel
