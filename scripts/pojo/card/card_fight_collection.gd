class_name CardFightCollection

@export var playerDesk: CardInfoCollection = CardInfoCollection.new()

func set_player_desk_info_collection(_collection: CardInfoCollection) -> CardFightCollection:
	playerDesk = _collection
	return self
func get_player_desk_info_collection() -> CardInfoCollection:
	return playerDesk

@export var playerHand: CardInfoCollection = CardInfoCollection.new()

func set_player_hand_info_collection(_collection: CardInfoCollection) -> CardFightCollection:
	playerHand = _collection
	return self
func get_player_hand_info_collection() -> CardInfoCollection:
	return playerHand
	
@export var enemyHand: CardInfoCollection = CardInfoCollection.new()

func set_enemy_hand_info_collection(_collection: CardInfoCollection) -> CardFightCollection:
	enemyHand = _collection
	return self
func get_enemy_hand_info_collection() -> CardInfoCollection:
	return enemyHand

@export var enemyDesk: CardInfoCollection = CardInfoCollection.new()

func set_enemy_desk_info_collection(_collection: CardInfoCollection) -> CardFightCollection:
	enemyDesk = _collection
	return self
func get_enemy_desk_info_collection() -> CardInfoCollection:
	return enemyDesk
