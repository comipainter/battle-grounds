class_name ShopCardCollection

var shopCollection: CardCollection = CardCollection.new()
func set_shop_collection(_collection: CardCollection) -> ShopCardCollection:
	shopCollection = _collection
	return self
func get_shop_collection() -> CardCollection:
	return shopCollection

var handCollection: CardCollection = CardCollection.new()
func set_hand_collection(_collection: CardCollection) -> ShopCardCollection:
	handCollection = _collection
	return self
func get_hand_collection() -> CardCollection:
	return handCollection

var deskCollection: CardCollection = CardCollection.new()
func set_desk_collection(_collection: CardCollection) -> ShopCardCollection:
	deskCollection = _collection
	return self
func get_desk_collection() -> CardCollection:
	return deskCollection

var freeCollection: CardCollection = CardCollection.new()
func set_free_collection(_collection: CardCollection) -> ShopCardCollection:
	freeCollection = _collection
	return self
func get_free_collection() -> CardCollection:
	return freeCollection
