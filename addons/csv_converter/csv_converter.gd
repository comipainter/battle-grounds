@tool
extends Node
class_name CsvConverter

## CSV转TRES转换器
## 将本地CSV卡牌数据文件转换为Godot资源文件(.tres)

const MINION_CSV = Path.DataPath.MINION_CSV
const MAGIC_CSV = Path.DataPath.MAGIC_CSV
const MINION_TRES = Path.DataPath.MINION_TRES
const MAGIC_TRES = Path.DataPath.MAGIC_TRES

## 转换所有CSV文件为TRES
static func convert_all() -> void:
	convert_minion_csv()
	convert_magic_csv()
	print("CSV转换完成!")


## 转换minion_data.csv为TRES
static func convert_minion_csv() -> MinionDataCollection:
	var csv_data: Array[Dictionary] = _read_csv(MINION_CSV)
	var collection: MinionDataCollection = MinionDataCollection.new()

	for row: Dictionary in csv_data:
		if row.get("useable", "0") != "1":
			continue
		var minion_data: MinionData = _parse_minion_row(row)
		collection.minionDataArray.append(minion_data)

	_save_tres(collection, MINION_TRES)
	print("Minion数据转换完成，共 %d 条 " % collection.minionDataArray.size())
	return collection


## 转换magic_data.csv为TRES
static func convert_magic_csv() -> MagicDataCollection:
	var csv_data: Array[Dictionary] = _read_csv(MAGIC_CSV)
	var collection: MagicDataCollection = MagicDataCollection.new()

	for row: Dictionary in csv_data:
		if row.get("useable", "0") != "1":
			continue
		var magic_data: MagicData = _parse_magic_row(row)
		collection.magicDataArray.append(magic_data)

	_save_tres(collection, MAGIC_TRES)
	print("Magic数据转换完成，共 %d 条" % collection.magicDataArray.size())
	return collection


## 读取CSV文件并解析为字典数组
static func _read_csv(path: String) -> Array[Dictionary]:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("无法打开CSV文件: %s" % path)
		return []

	var result: Array[Dictionary] = []

	# 读取标题行
	var headers: PackedStringArray = _parse_csv_line(file.get_line())

	# 读取数据行
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.is_empty():
			continue

		var values: PackedStringArray = _parse_csv_line(line)
		if values.size() != headers.size():
			push_warning("CSV行数据列数不匹配，跳过: %s" % line)
			continue

		var row: Dictionary = {}
		for i: int in headers.size():
			row[headers[i]] = values[i]
		result.append(row)

	file.close()
	return result


## 解析CSV行（处理逗号分隔）
static func _parse_csv_line(line: String) -> PackedStringArray:
	# 简单的CSV解析，按逗号分割
	# 如果需要处理带引号的字段，可以扩展此函数
	return line.split(",")


## 解析Minion数据行
static func _parse_minion_row(row: Dictionary) -> MinionData:
	var minion: MinionData = MinionData.new()

	minion.id = row.get("id", "0").to_int()
	minion.name = row.get("name", "")
	minion.level = row.get("level", "1").to_int()
	minion.description = row.get("description", "")
	minion.sellable = row.get("sellable", "0").to_int() == 1
	minion.attack = row.get("attack", "0").to_int()
	minion.health = row.get("health", "0").to_int()
	minion.goldenDescription = row.get("golden_description", "")
	minion.race = _parse_race(row.get("race", ""))

	# 解析关键词属性
	minion.shengdun = row.get("shengdun", "0").to_int() == 1
	minion.liedu = row.get("liedu", "0").to_int() == 1
	minion.fusheng = row.get("fusheng", "0").to_int() == 1
	minion.chaofeng = row.get("chaofeng", "0").to_int() == 1
	minion.fengnu = row.get("fengnu", "0").to_int() == 1
	
	# 解析磁力属性
	minion.cili = minion.description.begins_with("磁力。")
	
	# 设置精灵图路径（根据name生成）
	minion.spritePath = "res://assets/image/minion/%s.png" % minion.name

	return minion


## 解析Magic数据行
static func _parse_magic_row(row: Dictionary) -> MagicData:
	var magic: MagicData = MagicData.new()

	magic.id = row.get("id", "0").to_int()
	magic.name = row.get("name", "")
	magic.level = row.get("level", "1").to_int()
	magic.description = row.get("description", "")
	magic.sellable = row.get("sellable", "0").to_int() == 1
	magic.cost = row.get("cost", "0").to_int()
	magic.suzao = row.get("suzao", "0").to_int() == 1

	# 设置精灵图路径（根据name生成）
	magic.spritePath = "res://assets/image/magic/%s.png" % magic.name

	return magic


## 解析种族字符串为Race.Type枚举
static func _parse_race(race_str: String) -> Race.Type:
	match race_str:
		"中立":
			return Race.Type.ZhongLi
		"海盗":
			return Race.Type.HaiDao
		"元素（风）":
			return Race.Type.YuanSu_Wind | Race.Type.YuanSu
		"元素（水）":
			return Race.Type.YuanSu_Shui | Race.Type.YuanSu
		"元素（土）":
			return Race.Type.YuanSu_Tu | Race.Type.YuanSu
		"元素（火）":
			return Race.Type.YuanSu_Huo | Race.Type.YuanSu
		"元素":
			return Race.Type.YuanSu
		"娜迦":
			return Race.Type.NaJia
		_:
			return Race.Type.None


## 保存资源为TRES文件
static func _save_tres(resource: Resource, path: String) -> Error:
	var error: int = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("保存TRES文件失败: %s, 错误码: %d" % [path, error])
	return error
