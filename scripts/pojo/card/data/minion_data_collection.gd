extends Resource
class_name MinionDataCollection

@export var minionDataArray: Array[MinionData]

func _init(_array: Array[MinionData] = []) -> void:
	minionDataArray = _array.duplicate_deep()

func get_array() -> Array[MinionData]:
	return minionDataArray

func make_sellable_collection() -> MinionDataCollection:
	var selllableArray: Array[MinionData] = []
	for mininonData: MinionData in minionDataArray:
		if mininonData.is_sellable() == true:
			selllableArray.append(mininonData)
	return MinionDataCollection.new(
		selllableArray
	)

func add(minionData: MinionData) -> MinionDataCollection:
	minionDataArray.append(minionData)
	return self

func add_array(array: Array[MinionData]) -> MinionDataCollection:
	for minionData in array:
		minionDataArray.append(minionData)
	return self

func add_collection(collection: MinionDataCollection) -> MinionDataCollection:
	for minionData in collection.get_array():
		add(minionData)
	return self

func size() -> int:
	return get_array().size()

func pick_random() -> MinionData:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> MinionDataCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> MinionDataCollection:
	minionDataArray = get_array().slice(begin, end)
	return self

func erase(minionData: MinionData) -> MinionDataCollection:
	get_array().erase(minionData)
	return self

func copy() -> MinionDataCollection:
	var _collection: MinionDataCollection = MinionDataCollection.new()
	for data in get_array():
		_collection.add(data.copy())
	return _collection

func pick_random_collection(num: int, repeatable: bool) -> MinionDataCollection:
	var randomCollection: MinionDataCollection = MinionDataCollection.new()
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
	var race: Race.Type = Race.Type.None
	var level: int = -1
	var levelRange: Array #[min, max]
	var name: String = ""
	var id: int = -1
	var except_name: String = ""
	
	func set_except_name(_name: String) -> Filter:
		except_name = _name
		return self
		
	func set_id(_id: int) -> Filter:
		id = _id
		return self
	
	func set_name(_name: String) -> Filter:
		name = _name
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

	func match(minionData: MinionData) -> bool:
		if name != "" and minionData.get_card_name() != name:
			return false
		if race != Race.Type.None and minionData.get_race() & race == 0:
			return false
		if levelRange != []:
			if minionData.get_level() < levelRange[0] or minionData.get_level() > levelRange[1]:
				return false
		elif level != -1:
			if minionData.get_level() != level:
				return false
		if id != -1:
			if minionData.get_id() != id:
				return false
		if except_name != "":
			if minionData.get_card_name() == except_name:
				return false
		return true

func filter_by(f: Filter) -> MinionDataCollection:
	var collection: MinionDataCollection = MinionDataCollection.new()
	for minionData in get_array():
		if f.match(minionData):
			collection.add(minionData)
	return collection
