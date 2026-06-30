class_name MinionCollection

var array: Array[Minion] = []

func _init(_array: Array[Minion] = []) -> void:
	array = _array

func get_array() -> Array[Minion]:
	return array

func add(_minion: Minion) -> MinionCollection:
	array.append(_minion)
	return self

func add_array(_array: Array[Minion]) -> MinionCollection:
	for info in _array:
		array.append(info)
	return self

func add_collection(_collection: MinionCollection) -> MinionCollection:
	for minion in _collection.get_array():
		add(minion)
	return self

func size() -> int:
	return get_array().size()

func is_empty() -> bool:
	return get_array().is_empty()

func pick_random() -> Minion:
	if size() == 0:
		return null
	return get_array().pick_random()

func shuffle() -> MinionCollection:
	get_array().shuffle()
	return self

func slice(begin: int, end: int) -> MinionCollection:
	array = get_array().slice(begin, end)
	return self

func erase(minion: Minion) -> MinionCollection:
	get_array().erase(minion)
	return self
	
func pick_random_collection(num: int, repeatable: bool) -> MinionCollection:
	var randomCollection: MinionCollection = MinionCollection.new()
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
	var race: Race.Type = Race.Type.None
	var except_race: Race.Type = Race.Type.None
	var level: int = -1
	var levelRange: Array = [] #[min, max]
	var uniqueId: String = ""
	var id: int = -1
	var name: String = ""
	var except_name: String = ""
	
	func set_name(_name: String) -> Filter:
		name = _name
		return self
		
	func set_except_name(_name: String) -> Filter:
		except_name = _name
		return self
	
	func set_id(_id: int) -> Filter:
		id = _id
		return self

	func set_race(_race: Race.Type) -> Filter:
		race = _race
		return self
		
	func set_except_race(_race: Race.Type) -> Filter:
		except_race = _race
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

	func match(minion: Minion) -> bool:
		if race != Race.Type.None and minion.get_info().get_race() & race == 0:
			return false
		if except_race != Race.Type.None and minion.get_info().get_race() & except_race != 0:
			return false
		if levelRange != []:
			if minion.get_info().get_level() < levelRange[0] or minion.get_info().get_level() > levelRange[1]:
				return false
		elif level != -1:
			if minion.get_info().get_level() != level:
				return false
		if uniqueId != "":
			if minion.get_info().get_uniqueId() != uniqueId:
				return false
		if id != -1:
			if minion.get_info().get_id() != id:
				return false
		if name != "":
			if minion.get_info().get_card_name() != name:
				return false
		if except_name != "":
			if minion.get_info().get_card_name() == except_name:
				return false
		return true

func filter_by(f: Filter) -> MinionCollection:
	var collection: MinionCollection = MinionCollection.new()
	for minion in get_array():
		if f.match(minion):
			collection.add(minion)
	return collection

func sort_by_position() -> MinionCollection:
	array.sort_custom(func(a: Minion, b: Minion) -> bool:
		return a.global_position.x < b.global_position.x
	)
	return self

func sort_by_id() -> MinionCollection:
	array.sort_custom(func(a: Minion, b: Minion) -> bool:
		return a.get_info().get_id() < b.get_info().get_id()
	)
	return self

func get_adjacent_minions(minion: Minion) -> MinionCollection:
	var adjacentCollection: MinionCollection = MinionCollection.new()
	if minion == null or not minion in array:
		return adjacentCollection

	var target_x: float = minion.global_position.x
	var left_minion: Minion = null
	var right_minion: Minion = null
	var left_diff: float = 10000.0
	var right_diff: float = 10000.0

	for m in array:
		if m == minion:
			continue
		var diff: float = m.global_position.x - target_x
		if diff < 0 and abs(diff) < left_diff:
			left_diff = abs(diff)
			left_minion = m
		elif diff > 0 and diff < right_diff:
			right_diff = diff
			right_minion = m

	if left_minion != null:
		adjacentCollection.add(left_minion)
	if right_minion != null:
		adjacentCollection.add(right_minion)

	return adjacentCollection

func is_idle() -> bool:
	for minion in get_array():
		if minion.is_idle() == false:
			return false
	return true
	
func get_behit_minion() -> Minion:
	if size() == 0:
		push_error("find behit minion in NULL collection")
		return null
	var minion_array: Array[Minion] = []
	# 先把存活的随从选出来
	for minion: Minion in sort_by_position().get_array():
		if minion.get_info().get_stats().get_health() > 0:
			minion_array.append(minion)
	if minion_array.size() == 0:
		push_error("no minion live")
		return null
	# 有嘲讽随从先返回嘲讽随从
	var chaofengCollection: MinionCollection = MinionCollection.new()
	for minion: Minion in minion_array:
		if minion.get_info().get_keyword_info().is_chaofeng():
			chaofengCollection.add(minion)
	if chaofengCollection.size() != 0:
		return chaofengCollection.pick_random()
	return pick_random()

func get_live_collection() -> MinionCollection:
	var collection: MinionCollection = MinionCollection.new()
	for minion in array:
		if MinionUtils.is_alive(minion):
			collection.add(minion)
	return collection

func remove_unvaild() -> MinionCollection:
	array = array.filter(func(minion): return is_instance_valid(minion))
	return self
	
func remove_father(_minion: Minion) -> MinionCollection:
	if is_instance_valid(_minion.get_father()):
		array.erase(_minion.get_father())
	return self

func remove_undesk() -> MinionCollection:
	array = array.filter(
		func(minion): return minion.get_info().is_shopping_desk()
	)
	return self

func remove_ronghe() -> MinionCollection:
	array = array.filter(
		func(minion): return !minion.get_info().is_ronghe()
	)
	return self

func get_most_race() -> Race.Type:
	var race_count := {}
	var _collection = self.filter_by(
		Filter.new().set_except_race(Race.Type.ZhongLi)
	).filter_by(
		Filter.new().set_except_race(Race.Type.None)
	)
	for _minion in _collection.get_array():
		var original_race: Race.Type = _minion.get_info().get_race()
		var race_to_count: Race.Type = original_race
		
		# 判断是否为元素大类
		if original_race & Race.Type.YuanSu:
			race_to_count = Race.Type.YuanSu
		
		if race_count.has(race_to_count):
			race_count[race_to_count] += 1
		else:
			race_count[race_to_count] = 1
			
	# 2. 找出占多数的种族（支持平票随机）
	var majority_race: Race.Type = Race.Type.None

	if not race_count.is_empty():
		# 第一步：获取字典中最大的数量
		var max_count = race_count.values().max()
		
		# 第二步：收集所有数量等于最大值的种族
		var top_races: Array[Race.Type] = []
		for race in race_count.keys():
			if race_count[race] == max_count:
				top_races.append(race)
		
		# 第三步：从并列第一的种族中随机抽取一个
		majority_race = top_races.pick_random()
	
	return majority_race
