extends Resource
class_name CardInfoCollection

@export var cardInfoArray: Array[CardInfo] = []

func _init(_array: Array[CardInfo] = []) -> void:
	cardInfoArray = _array

func get_array() -> Array[CardInfo]:
	return cardInfoArray

func make_sellable_collection() -> CardInfoCollection:
	var selllableArray: Array[CardInfo] = []
	for cardInfo: CardInfo in cardInfoArray:
		if cardInfo.is_sellable() == true:
			selllableArray.append(cardInfo.duplicate_deep())
	return CardInfoCollection.new(
		selllableArray
	)

func add(cardInfo: CardInfo) -> CardInfoCollection:
	cardInfoArray.append(cardInfo)
	return self

func add_array(array: Array[CardInfo]) -> CardInfoCollection:
	for info in array:
		cardInfoArray.append(info)
	return self

func add_collection(collection: CardInfoCollection) -> CardInfoCollection:
	for cardInfo in collection.get_array():
		add(cardInfo)
	return self
	
func add_minion_collection(collection: MinionInfoCollection) -> CardInfoCollection:
	for minionInfo in collection.get_array():
		add(minionInfo)
	return self

func add_magic_collection(collection: MagicInfoCollection) -> CardInfoCollection:
	for magicInfo in collection.get_array():
		add(magicInfo)
	return self

func get_minion_collection() -> MinionInfoCollection:
	var _collection: MinionInfoCollection = MinionInfoCollection.new()
	for info: CardInfo in get_array():
		if info.is_minion():
			_collection.add(info as MinionInfo)
	return _collection
	
func get_magic_collection() -> MagicInfoCollection:
	var _collection: MagicInfoCollection = MagicInfoCollection.new()
	for info: CardInfo in get_array():
		if info.is_minion():
			_collection.add(info as MagicInfo)
	return _collection

func size() -> int:
	return get_array().size()

func is_empty() -> bool:
	return get_array().is_empty()

func pick_random() -> CardInfo:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> CardInfoCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> CardInfoCollection:
	cardInfoArray = get_array().slice(begin, end)
	return self

func erase(cardInfo: CardInfo) -> CardInfoCollection:
	get_array().erase(cardInfo)
	return self
	
func copy() -> CardInfoCollection:
	var _collection: CardInfoCollection = CardInfoCollection.new()
	for info in get_array():
		_collection.add(info.copy())
	return _collection
	
func pick_random_collection(num: int, repeatable: bool) -> CardInfoCollection:
	var randomCollection: CardInfoCollection = CardInfoCollection.new()
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
	var uniqueId: String = ""
	
	func set_uniqueId(_uniqueId: String) -> Filter:
		uniqueId = _uniqueId
		return self

	func set_name(_name: String) -> Filter:
		name = _name
		return self

	func set_level(_level: int) -> Filter:
		level = _level
		return self

	func set_level_range(min_level: int, max_level: int) -> Filter:
		levelRange = [min_level, max_level]
		return self

	func match(info: CardInfo) -> bool:
		if name != "" and info.get_card_name() != name:
			return false
		if levelRange != []:
			if info.get_level() < levelRange[0] or info.get_level() > levelRange[1]:
				return false
		elif level != -1:
			if info.get_level() != level:
				return false
		if uniqueId != "":
			if info.get_uniqueId() != uniqueId:
				return false
		return true

func filter_by(f: Filter) -> CardInfoCollection:
	var collection: CardInfoCollection = CardInfoCollection.new()
	for info in get_array():
		if f.match(info):
			collection.add(info)
	return collection
