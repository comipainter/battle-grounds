class_name CardShopCollection

@export var shop: CardInfoCollection = CardInfoCollection.new()
func set_shop_info_collection(_collection: CardInfoCollection) -> CardShopCollection:
	shop = _collection
	return self
func get_shop_info_collection() -> CardInfoCollection:
	return shop
	
@export var playerDesk: CardInfoCollection = CardInfoCollection.new()

func set_player_desk_info_collection(_collection: CardInfoCollection) -> CardShopCollection:
	playerDesk = _collection
	return self
func get_player_desk_info_collection() -> CardInfoCollection:
	return playerDesk

@export var playerHand: CardInfoCollection = CardInfoCollection.new()

func set_player_hand_info_collection(_collection: CardInfoCollection) -> CardShopCollection:
	playerHand = _collection
	return self
func get_player_hand_info_collection() -> CardInfoCollection:
	return playerHand
