class_name MagicCollection

var array: Array[Magic] = []

func _init(_array: Array[Magic] = []) -> void:
	array = _array

func get_array() -> Array[Magic]:
	return array

func add(_minion: Magic) -> MagicCollection:
	array.append(_minion)
	return self

func add_array(_array: Array[Magic]) -> MagicCollection:
	for info in _array:
		array.append(info)
	return self

func add_collection(_collection: MagicCollection) -> MagicCollection:
	for magic in _collection.get_array():
		add(magic)
	return self

func size() -> int:
	return get_array().size()

func is_empty() -> bool:
	return get_array().is_empty()

func pick_random() -> Magic:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> MagicCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> MagicCollection:
	array = get_array().slice(begin, end)
	return self

func erase(magic: Magic) -> MagicCollection:
	get_array().erase(magic)
	return self
	
func pick_random_collection(num: int, repeatable: bool) -> MagicCollection:
	var randomCollection: MagicCollection = MagicCollection.new()
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
			randomCollection = self.shuffle().slice(0, num)
	return randomCollection

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

	func match(magic: Magic) -> bool:
		if levelRange != []:
			if magic.get_info().get_level() < levelRange[0] or magic.get_info().get_level() > levelRange[1]:
				return false
		elif level != -1:
			if magic.get_info().get_level() != level:
				return false
		if uniqueId != "":
			if magic.get_info().get_uniqueId() != uniqueId:
				return false
		return true

func filter_by(f: Filter) -> MagicCollection:
	var collection: MagicCollection = MagicCollection.new()
	for magic in get_array():
		if f.match(magic):
			collection.add(magic)
	return collection
