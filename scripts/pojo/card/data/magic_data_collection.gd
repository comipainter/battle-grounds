extends Resource
class_name MagicDataCollection

@export var magicDataArray: Array[MagicData]

func _init(_array: Array[MagicData] = []) -> void:
	magicDataArray = _array.duplicate_deep()

func get_array() -> Array[MagicData]:
	return magicDataArray

func make_sellable_collection() -> MagicDataCollection:
	var selllableArray: Array[MagicData] = []
	for magicData: MagicData in magicDataArray:
		if magicData.is_sellable() == true:
			selllableArray.append(magicData)
	return MagicDataCollection.new(
		selllableArray
	)

func add(magicData: MagicData) -> MagicDataCollection:
	magicDataArray.append(magicData)
	return self

func add_array(array:Array[MagicData]) -> MagicDataCollection:
	for magicData in array:
		magicDataArray.append(magicData)
	return self

func add_collection(collection: MagicDataCollection) -> MagicDataCollection:
	for magicData in collection.get_array():
		add(magicData)
	return self

func size() -> int:
	return get_array().size()

func pick_random() -> MagicData:
	if size() == 0:
		return null
	return get_array().pick_random()
	
func shuffle() -> MagicDataCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> MagicDataCollection:
	magicDataArray = get_array().slice(begin, end)
	return self

func erase(magicData: MagicData) -> MagicDataCollection:
	get_array().erase(magicData)
	return self
	
func copy() -> MagicDataCollection:
	var _collection: MagicDataCollection = MagicDataCollection.new()
	for data in get_array():
		_collection.add(data.copy())
	return _collection

func pick_random_collection(num: int = 1, repeatable: bool = true) -> MagicDataCollection:
	var randomCollection: MagicDataCollection = MagicDataCollection.new()
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
	var levelRange: Array #[min, max]
	var name: String = ""
	var suzao: int = -1
	var contain_name: String = ""
	
	func set_suzao(_suzao: bool) -> Filter:
		if _suzao == true:
			suzao = 1
		elif _suzao == false:
			suzao = 0
		return self

	func set_name(_name: String) -> Filter:
		name = _name
		return self
		
	func set_contain_name(_name: String) -> Filter:
		contain_name = _name
		return self

	func set_level(_level: int) -> Filter:
		level = _level
		return self

	func set_level_range(min_level: int, max_level: int) -> Filter:
		levelRange = [min_level, max_level]
		return self

	func match(magicData: MagicData) -> bool:
		if suzao != -1:
			if magicData.is_suzao() == true and suzao == 0:
				return false
			if magicData.is_suzao() == false and suzao == 1:
				return false
		if name != "":
			if magicData.get_card_name() != name:
				return false
		if contain_name != "":
			if magicData.get_card_name().contains(contain_name) == false:
				return false
		if levelRange != []:
			if magicData.get_level() < levelRange[0] or magicData.get_level() > levelRange[1]:
				return false
		elif level != -1:
			if magicData.get_level() != level:
				return false
		return true

func filter_by(f: Filter) -> MagicDataCollection:
	var collection: MagicDataCollection = MagicDataCollection.new()
	for magicData in get_array():
		if f.match(magicData):
			collection.add(magicData)
	return collection
