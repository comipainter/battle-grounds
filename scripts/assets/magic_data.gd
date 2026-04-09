class_name MagicData

# 从文档中加载法术数据
static func load_allMagicInfo_from_csv(path) -> Array[MagicInfo]:
	var infoList: Array[MagicInfo] = []
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 2:
			var row_dict = {}
			for i in range(0, headers.size()):
				# 如果headers[i]=="cost"则转换数字类型
				if headers[i] == "cost" or headers[i] == "level" or headers[i] == "id" or headers[i] == "inner_id":
					row_dict[headers[i]] = int(values[i]) if values[i].is_valid_int() else 0
				else:
					row_dict[headers[i]] = values[i]
			row_dict["type"] = "magic"
			row_dict["sprite_path"] = str("res://assets/image/magic/") + str(row_dict["name"]) + ".png"
			infoList.append(MagicInfo.new(row_dict))
	file.close()
	return infoList

# 从文档中加载售卖法术
static func load_shopMagicInfo_from_csv(path) -> Array[MagicInfo]:
	var infoList: Array[MagicInfo] = []
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 2:
			var row_dict = {}
			for i in range(0, headers.size()):
				# 如果headers[i]=="cost"则转换数字类型
				if headers[i] == "cost" or headers[i] == "level" or headers[i] == "id" or headers[i] == "inner_id":
					row_dict[headers[i]] = int(values[i]) if values[i].is_valid_int() else 0
				else:
					row_dict[headers[i]] = values[i]
			if row_dict["sellable"] != "1":
				continue
			row_dict["type"] = "magic"
			row_dict["sprite_path"] = str("res://assets/image/magic/") + str(row_dict["name"]) + ".png"
			infoList.append(MagicInfo.new(row_dict))
	file.close()
	return infoList

# 从其中随机选出一个法术牌信息
static func get_random_magic() -> MagicInfo:
	return GameManager.allMagicInfo.pick_random().duplicate()
	
# 从固定本数以下随机选出一个法术
static func get_random_magic_under_level(magicInfoList: Array[MagicInfo], level: int) -> MagicInfo:
	var validInfo: Array[MagicInfo] = []
	for magicInfo in magicInfoList:
		if magicInfo.level <= level:
			validInfo.append(magicInfo)
	if validInfo.is_empty():
		push_error("No minions found at level %d" % level)
		return null
	return validInfo.pick_random().duplicate()

# 从固定本数中随机选出一个法术
static func get_random_magic_in_level(magicInfoList: Array[MagicInfo], level: int) -> MagicInfo:
	var validInfo: Array[MagicInfo] = []
	for magicInfo in magicInfoList:
		if magicInfo.level == level:
			validInfo.append(magicInfo)
	if validInfo.is_empty():
		push_error("No minions found at level %d" % level)
		return null
	return validInfo.pick_random().duplicate()
	
# 查询id法术
static func get_magic_by_id(magicInfoList: Array[MagicInfo], id: int) -> MagicInfo:
	for magicInfo in magicInfoList:
		if magicInfo.id == id:
			return magicInfo.duplicate()
	push_error("Minion with id %d not found" % id)
	return null

# 查询法术名称
static func get_magic_by_name(magicInfoList: Array[MagicInfo], name: String) -> MagicInfo:
	for magicInfo in magicInfoList:
		if magicInfo.name == name:
			return magicInfo.duplicate()
	push_error("Minion with name %d not found" % name)
	return null
