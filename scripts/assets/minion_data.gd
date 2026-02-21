class_name MinionData

static func load_allMinionInfo_from_csv(path) -> Array[MinionInfo]:
	var infoList: Array[MinionInfo] = []
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 2:
			var key = values[0]
			var row_dict = {}
			for i in range(0, headers.size()):
				# 如果headers[i]=="attack"/"health"则转换数字类型
				if headers[i] == "attack" or headers[i] == "health" or headers[i] == "level" or  headers[i] == "id" or headers[i] == "inner_id":
					row_dict[headers[i]] = int(values[i]) if values[i].is_valid_int() else 0
				else:
					row_dict[headers[i]] = values[i]
			row_dict["type"] = "minion"
			row_dict["golden"] = 0
			row_dict["sprite_path"] = str("res://assets/image/minion/") + str(row_dict["name"]) + ".png"
			infoList.append(MinionInfo.new(row_dict))
	file.close()
	return infoList


# 从其中随机选出一个随从的信息
static func get_random_minion() -> MinionInfo:
	return GameManager.allMinionInfo.pick_random().create()

# 从固定本数以下随机选出一个随从
static func get_random_minion_under_level(level: int) -> MinionInfo:
	var allMinionInfo = GameManager.allMinionInfo
	var validInfo: Array[MinionInfo] = []
	for minionInfo in allMinionInfo:
		if minionInfo.level <= level:
			validInfo.append(minionInfo)
	if validInfo.is_empty():
		push_error("No minions found at level %d" % level)
		return null
	return validInfo.pick_random().create()

# 从固定本数中随机选出一个随从
static func get_random_minion_in_level(level: int) -> MinionInfo:
	var allMinionInfo = GameManager.allMinionInfo
	var validInfo: Array[MinionInfo] = []
	for minionInfo in allMinionInfo:
		if minionInfo.level == level:
			validInfo.append(minionInfo)
	if validInfo.is_empty():
		push_error("No minions found at level %d" % level)
		return null
	return validInfo.pick_random().create()

# 查询id随从
static func get_minion_by_id(id: int) -> MinionInfo:
	var allMinionInfo = GameManager.allMinionInfo
	for minionInfo in allMinionInfo:
		if  minionInfo.id == id:
			return minionInfo.create()
	push_error("Minion with id %d not found" % id)
	return null
	
# 查询随从名称
static func get_minion_by_name(name: int) -> MinionInfo:
	var allMinionInfo = GameManager.allMinionInfo
	for minionInfo in allMinionInfo:
		if  minionInfo.name == name:
			return minionInfo.create()
	push_error("Minion with name %d not found" % name)
	return null
	
# 在固定本数以下、固定种族中随机选出一个随从
static func get_random_minion_in_race_under_level(level: int, race: String) -> MinionInfo:
	var allMinionInfo = GameManager.allMinionInfo
	var validInfo: Array[MinionInfo] = []
	for minionInfo in allMinionInfo:
		if minionInfo.level <= level and minionInfo.race == race:
			validInfo.append(minionInfo)
	if validInfo.is_empty():
		push_error("No minions found at level %d" % level)
		return null
	return validInfo.pick_random().create()

# 数学方法
static func add_info(minionInfo1: MinionInfo, minionInfo2: MinionInfo) -> MinionInfo:
	var info: MinionInfo = minionInfo1.duplicate()
	info.attack += minionInfo2.attack
	info.health += minionInfo2.health
	return info
	
static func sub_info(minionInfo1: MinionInfo, minionInfo2: MinionInfo) -> MinionInfo:
	var info: MinionInfo = minionInfo1.duplicate()
	info.attack -= minionInfo2.attack
	info.health -= minionInfo2.health
	return info
	
static func double_info(info: MinionInfo) -> MinionInfo:
	return add_info(info, info)
