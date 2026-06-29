extends Resource
class_name FightInfo

func copy() -> FightInfo:
	var _info: FightInfo = duplicate(true)
	_info.set_player_hand_info_collection(
		get_player_hand_info_collection().copy()
	)
	_info.set_player_desk_info_collection(
		get_player_desk_info_collection().copy()
	)
	_info.set_enemy_hand_info_collection(
		get_enemy_hand_info_collection().copy()
	)
	_info.set_enemy_desk_info_collection(
		get_enemy_desk_info_collection().copy()
	)
	return _info

@export var enemyHand: CardInfoCollection = CardInfoCollection.new()

func set_enemy_hand_info_collection(_collection: CardInfoCollection) -> void:
	enemyHand = _collection
func get_enemy_hand_info_collection() -> CardInfoCollection:
	return enemyHand

@export var enemyDesk: CardInfoCollection = CardInfoCollection.new()

func set_enemy_desk_info_collection(_collection: CardInfoCollection) -> void:
	enemyDesk = _collection
func get_enemy_desk_info_collection() -> CardInfoCollection:
	return enemyDesk
	
@export var enemyFree: CardInfoCollection = CardInfoCollection.new()

func set_enemy_free_info_collection(_collection: CardInfoCollection) -> void:
	enemyFree = _collection
func get_enemy_free_info_collection() -> CardInfoCollection:
	return enemyFree

@export var playerDesk: CardInfoCollection = CardInfoCollection.new()

func set_player_desk_info_collection(_collection: CardInfoCollection) -> void:
	playerDesk = _collection
func get_player_desk_info_collection() -> CardInfoCollection:
	return playerDesk

@export var playerHand: CardInfoCollection = CardInfoCollection.new()

func set_player_hand_info_collection(_collection: CardInfoCollection) -> void:
	playerHand = _collection
func get_player_hand_info_collection() -> CardInfoCollection:
	return playerHand

@export var playerFree: CardInfoCollection = CardInfoCollection.new()

func set_player_free_info_collection(_collection: CardInfoCollection) -> void:
	playerFree = _collection
func get_player_free_info_collection() -> CardInfoCollection:
	return playerFree
	

signal enemy_hand_created
func create_enemy_hand_card_info(info: CardInfo, position: Vector2) -> void:
	if DataManager.get_enemy_info().get_hand_card_num() == enemyHand.size():
		return
	_add_to_enemy_hand(info)
	enemy_hand_created.emit(info, position)
signal enemy_desk_created
func create_enemy_desk_card_info(info: CardInfo, position: Vector2) -> void:
	if DataManager.get_enemy_info().get_desk_card_num() == enemyDesk.size():
		return
	_add_to_enemy_desk(info)
	enemy_desk_created.emit(info, position)
signal enemy_free_created
func create_enemy_free_card_info(info: CardInfo, position: Vector2) -> void:
	_add_to_enemy_free(info)
	enemy_free_created.emit(info, position)
signal player_hand_created
func create_player_hand_card_info(info: CardInfo, position: Vector2) -> void:
	if DataManager.get_player_info().get_hand_card_num() == playerHand.size():
		return
	_add_to_player_hand(info)
	player_hand_created.emit(info, position)
signal player_desk_created
func create_player_desk_card_info(info: CardInfo, position: Vector2) -> void:
	if DataManager.get_player_info().get_desk_card_num() == playerDesk.size():
		return
	_add_to_player_desk(info)
	player_desk_created.emit(info, position)
signal player_free_created
func create_player_free_card_info(info: CardInfo, position: Vector2) -> void:
	_add_to_player_free(info)
	player_free_created.emit(info, position)
	
signal enemy_hand_removed
func _remove_enemy_hand_card_info(info: CardInfo) -> void:
	enemyHand.erase(info)
	info.set_enemy_free()
	_add_to_enemy_free(info)
	enemy_hand_removed.emit(info)
signal enemy_desk_removed
func _remove_enemy_desk_card_info(info: CardInfo) -> void:
	enemyDesk.erase(info)
	info.set_enemy_free()
	_add_to_enemy_free(info)
	enemy_desk_removed.emit(info)
signal player_hand_removed
func _remove_player_hand_card_info(info: CardInfo) -> void:
	playerHand.erase(info)
	info.set_player_free()
	_add_to_player_free(info)
	player_hand_removed.emit(info)
signal player_desk_removed
func _remove_player_desk_card_info(info: CardInfo) -> void:
	playerDesk.erase(info)
	info.set_player_free()
	_add_to_player_free(info)
	player_desk_removed.emit(info)
	
signal enemy_hand_added
func _add_to_enemy_hand(info: CardInfo) -> void:
	if DataManager.get_enemy_info().get_hand_card_num() == enemyHand.size():
		return
	enemyHand.add(info)
	info.set_enemy_hand()
	enemy_hand_added.emit(info)
signal enemy_desk_added
func _add_to_enemy_desk(info: CardInfo) -> void:
	if DataManager.get_enemy_info().get_desk_card_num() == enemyDesk.size():
		return
	enemyDesk.add(info)
	info.set_enemy_desk()
	enemy_desk_added.emit(info)
signal enemy_free_added
func _add_to_enemy_free(info: CardInfo) -> void:
	enemyFree.add(info)
	info.set_enemy_free()
	enemy_free_added.emit(info)
signal player_hand_added
func _add_to_player_hand(info: CardInfo) -> void:
	if DataManager.get_player_info().get_hand_card_num() == playerHand.size():
		return
	playerHand.add(info)
	info.set_player_hand()
	player_hand_added.emit(info)
signal player_desk_added
func _add_to_player_desk(info: CardInfo) -> void:
	if DataManager.get_player_info().get_desk_card_num() == playerDesk.size():
		return
	playerDesk.add(info)
	info.set_player_desk()
	player_desk_added.emit(info)
signal player_free_added
func _add_to_player_free(info: CardInfo) -> void:
	playerFree.add(info)
	info.set_player_free()
	player_free_added.emit(info)
	
signal removed
func _remove_card_info(info: CardInfo) -> void:
	if info.is_player_desk():
		_remove_player_desk_card_info(info)
	elif info.is_player_hand():
		_remove_player_hand_card_info(info)
	elif info.is_enemy_desk():
		_remove_enemy_desk_card_info(info)
	elif info.is_enemy_hand():
		_remove_enemy_hand_card_info(info)
func remove_card_info(info: CardInfo) -> void:
	_remove_card_info(info)
	removed.emit(info)

signal moved_to_player_desk
func move_card_to_player_desk(info: CardInfo) -> void:
	if DataManager.get_player_info().get_desk_card_num() == playerDesk.size():
		return
	_remove_card_info(info)
	playerFree.erase(info)
	enemyFree.erase(info)
	_add_to_player_desk(info)
	moved_to_player_desk.emit(info)
signal moved_to_player_hand
func move_card_to_player_hand(info: CardInfo) -> void:
	if DataManager.get_player_info().get_hand_card_num() == playerHand.size():
		return
	_remove_card_info(info)
	playerFree.erase(info)
	enemyFree.erase(info)
	_add_to_player_hand(info)
	moved_to_player_hand.emit(info)
signal moved_to_enemy_desk
func move_card_to_enemy_desk(info: CardInfo) -> void:
	if DataManager.get_enemy_info().get_desk_card_num() == enemyDesk.size():
		return
	_remove_card_info(info)
	playerFree.erase(info)
	enemyFree.erase(info)
	_add_to_enemy_desk(info)
	moved_to_enemy_desk.emit(info)
signal moved_to_enemy_hand
func move_card_to_enemy_hand(info: CardInfo) -> void:
	if DataManager.get_enemy_info().get_hand_card_num() == enemyHand.size():
		return
	_remove_card_info(info)
	playerFree.erase(info)
	enemyFree.erase(info)
	_add_to_enemy_hand(info)
	moved_to_enemy_hand.emit(info)

signal deleted
func delete_card_info(info: CardInfo) -> void:
	_remove_card_info(info)
	playerFree.erase(info)
	enemyFree.erase(info)
	deleted.emit(info)
