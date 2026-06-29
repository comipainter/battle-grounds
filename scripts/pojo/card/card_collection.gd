class_name CardCollection

var array: Array[Card]

func _init(_array: Array[Card] = []) -> void:
	array = _array
	
func get_array() -> Array[Card]:
	return array

func size() -> int:
	return array.size()

func add(card: Card) -> CardCollection:
	array.append(card)
	return self

func add_array(_array: Array[Card]) -> CardCollection:
	for card in _array:
		add(card)
	return self
	
func add_collection(_collection: CardCollection) -> CardCollection:
	return add_array(_collection.get_array())

func get_minion_collection() -> MinionCollection:
	var _collection: MinionCollection = MinionCollection.new()
	for card: Card in get_array():
		if card.get_info().is_minion():
			_collection.add(card as Minion)
	return _collection
	
func get_magic_collection() -> MagicCollection:
	var _collection: MagicCollection = MagicCollection.new()
	for card: Card in get_array():
		if card.get_info().is_magic():
			_collection.add(card as Magic)
	return _collection

func is_all_idle() -> bool:
	for card: Card in get_array():
		if card.is_idle() == false:
			return false
	return true

class Filter:
	var level: int = -1
	var levelRange: Array = [] #[min, max]
	var uniqueId: String = ""

	func set_level(_level: int) -> Filter:
		level = _level
		return self

	func set_level_range(min_level: int, max_level: int) -> Filter:
		levelRange = [min_level, max_level]
		return self
		
	func set_uniqueId(_uniqueId: String) -> Filter:
		uniqueId = _uniqueId
		return self

	func match(card: Card) -> bool:
		if levelRange != []:
			if card.get_info().get_level() < levelRange[0] or card.get_info().get_level() > levelRange[1]:
				return false
		elif level != -1:
			if card.get_info().get_level() != level:
				return false
		if uniqueId != "":
			if card.get_info().get_uniqueId() != uniqueId:
				return false
		return true

func filter_by(f: Filter) -> CardCollection:
	var collection: CardCollection = CardCollection.new()
	for card in get_array():
		if f.match(card):
			collection.add(card)
	return collection
