extends Resource
class_name MinionInfoCollection

var minionInfoArray: Array[MinionInfo] = []

func _init(_array: Array[MinionInfo] = []) -> void:
	minionInfoArray = _array

func get_array() -> Array[MinionInfo]:
	return minionInfoArray

func make_sellable_collection() -> MinionInfoCollection:
	var selllableArray: Array[MinionInfo] = []
	for minionInfo: MinionInfo in minionInfoArray:
		if minionInfo.is_sellable() == true:
			selllableArray.append(minionInfo.duplicate_deep())
	return MinionInfoCollection.new(
		selllableArray
	)

func add(minionInfo: MinionInfo) -> MinionInfoCollection:
	minionInfoArray.append(minionInfo)
	return self

func add_array(array: Array[MinionInfo]) -> MinionInfoCollection:
	for info in array:
		minionInfoArray.append(info)
	return self

func add_collection(collection: MinionInfoCollection) -> MinionInfoCollection:
	for minionInfo in collection.get_array():
		add(minionInfo)
	return self

func size() -> int:
	return get_array().size()

func is_empty() -> bool:
	return get_array().is_empty()

func pick_random() -> MinionInfo:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> MinionInfoCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> MinionInfoCollection:
	minionInfoArray = get_array().slice(begin, end)
	return self

func erase(minionInfo: MinionInfo) -> MinionInfoCollection:
	get_array().erase(minionInfo)
	return self

func copy() -> MinionInfoCollection:
	var _collection: MinionInfoCollection = MinionInfoCollection.new()
	for info in get_array():
		_collection.add(info.copy())
	return _collection
	
func pick_random_collection(num: int, repeatable: bool) -> MinionInfoCollection:
	var randomCollection: MinionInfoCollection = MinionInfoCollection.new()
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

func get_by_unique_id(uniqueId: int) -> MinionInfo:
	for minionInfo: MinionInfo in minionInfoArray:
		if minionInfo.get_unique_id() == uniqueId:
			return minionInfo
	return null

class Filter:
	var race: Race.Type = Race.Type.None
	var level: int = -1
	var levelRange: Array = [] #[min, max]
	var uniqueId: String = ""
	var id: int = -1
	
	func set_id(_id: int) -> Filter:
		id = _id
		return self

	func set_race(_race: Race.Type) -> Filter:
		race = _race
		return self

	func set_level(_level: int) -> Filter:
		level = _level
		return self

	func set_level_range(min_level: int, max_level: int) -> Filter:
		levelRange = [min_level, max_level]
		return self
		
	func set_uniqueId(_uniqueId: String) -> Filter:
		uniqueId = _uniqueId
		return self

	func match(info: MinionInfo) -> bool:
		if race != Race.Type.None and info.get_race() & race == 0:
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
		if id != -1:
			if info.get_id() != id:
				return false
		return true

func filter_by(f: Filter) -> MinionInfoCollection:
	var collection: MinionInfoCollection = MinionInfoCollection.new()
	for info in get_array():
		if f.match(info):
			collection.add(info)
	return collection
