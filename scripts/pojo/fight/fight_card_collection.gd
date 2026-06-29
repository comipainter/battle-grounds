class_name FightCardCollection

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
	
