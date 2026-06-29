extends Resource
class_name MagicInfoCollection

var magicInfoArray: Array[MagicInfo] = []

func _init(_array: Array[MagicInfo] = []) -> void:
	magicInfoArray = _array

func get_array() -> Array[MagicInfo]:
	return magicInfoArray

func make_sellable_collection() -> MagicInfoCollection:
	var selllableArray: Array[MagicInfo] = []
	for magicInfo: MagicInfo in magicInfoArray:
		if magicInfo.is_sellable() == true:
			selllableArray.append(magicInfo.duplicate_deep())
	return MagicInfoCollection.new(
		selllableArray
	)

func add(magicInfo: MagicInfo) -> MagicInfoCollection:
	magicInfoArray.append(magicInfo)
	return self

func add_array(array: Array[MagicInfo]) -> MagicInfoCollection:
	for info in array:
		magicInfoArray.append(info)
	return self

func add_collection(collection: MagicInfoCollection) -> MagicInfoCollection:
	for magicInfo in collection.get_array():
		add(magicInfo)
	return self

func size() -> int:
	return get_array().size()

func is_empty() -> bool:
	return get_array().is_empty()

func pick_random() -> MagicInfo:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> MagicInfoCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> MagicInfoCollection:
	magicInfoArray = get_array().slice(begin, end)
	return self

func erase(magicInfo: MagicInfo) -> MagicInfoCollection:
	get_array().erase(magicInfo)
	return self

func copy() -> MagicInfoCollection:
	var _collection: MagicInfoCollection = MagicInfoCollection.new()
	for info in get_array():
		_collection.add(info.copy())
	return _collection

func pick_random_collection(num: int, repeatable: bool) -> MagicInfoCollection:
	var randomCollection: MagicInfoCollection = MagicInfoCollection.new()
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

func get_by_unique_id(uniqueId: int) -> MagicInfo:
	for magicInfo: MagicInfo in magicInfoArray:
		if magicInfo.get_unique_id() == uniqueId:
			return magicInfo
	return null
