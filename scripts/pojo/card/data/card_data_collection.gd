extends Resource
class_name CardDataCollection

@export var cardDataArray: Array[CardData] = []

func _init(_array: Array[CardData] = []) -> void:
	cardDataArray = _array.duplicate_deep()

func get_array() -> Array[CardData]:
	return cardDataArray

func make_sellable_collection() -> CardDataCollection:
	var selllableArray: Array[CardData] = []
	for cardData: CardData in cardDataArray:
		if cardData.is_sellable() == true:
			selllableArray.append(cardData)
	return CardDataCollection.new(
		selllableArray
	)

func add(cardData: CardData) -> CardDataCollection:
	cardDataArray.append(cardData)
	return self

func add_array(array: Array[CardData]) -> CardDataCollection:
	for data in array:
		cardDataArray.append(data)
	return self

func add_collection(collection: CardDataCollection) -> CardDataCollection:
	for cardData in collection.get_array():
		add(cardData)
	return self

func size() -> int:
	return get_array().size()

func pick_random() -> CardData:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> CardDataCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> CardDataCollection:
	cardDataArray = get_array().slice(begin, end)
	return self

func erase(cardData: CardData) -> CardDataCollection:
	get_array().erase(cardData)
	return self

func copy() -> CardDataCollection:
	var _collection: CardDataCollection = CardDataCollection.new()
	for data: CardData in get_array():
		_collection.add(data.copy())
	return _collection

func pick_random_collection(num: int, repeatable: bool) -> CardDataCollection:
	var randomCollection: CardDataCollection = CardDataCollection.new()
	if repeatable:
		for i in range(num):
			randomCollection.add(pick_random())
	else:
		if size() < num:
			while size() < num:
				randomCollection.add_collection(self)
				num -= size()
			randomCollection.add_collection(shuffle().slice(0, num))
		else:
			randomCollection = shuffle().slice(0, num)
	return randomCollection

class Filter:
	var level: int = -1
	var levelRange: Array = [] #[min, max]
	var name: String = ""

	func set_name(_name: String) -> Filter:
		name = _name
		return self

	func set_level(_level: int) -> Filter:
		level = _level
		return self

	func set_level_range(min_level: int, max_level: int) -> Filter:
		levelRange = [min_level, max_level]
		return self

	func match(data: CardData) -> bool:
		if name != "" and data.get_card_name() != name:
			return false
		if levelRange != []:
			if data.get_level() < levelRange[0] or data.get_level() > levelRange[1]:
				return false
		elif level != -1:
			if data.get_level() != level:
				return false
		return true

func filter_by(f: Filter) -> CardDataCollection:
	var collection: CardDataCollection = CardDataCollection.new()
	for card in get_array():
		if f.match(card):
			collection.add(card)
	return collection
