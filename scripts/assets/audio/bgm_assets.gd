
class_name BgmAssets

## 背景音乐目录路径
const BGM_DIR := "res://assets/audio/background"

## 音乐名称到文件路径的映射
var bgm_library: Dictionary = {}

func _init() -> void:
	_load_bgm_library()

## 从背景音乐目录加载所有音乐文件并提取名称
func _load_bgm_library() -> void:
	var dir := DirAccess.open(BGM_DIR)
	if dir == null:
		push_error("无法打开背景音乐目录: " + BGM_DIR)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		# 跳过目录和 .import 文件
		if not dir.current_is_dir() and file_name.ends_with(".mp3"):
			var full_path := BGM_DIR.path_join(file_name)
			var music_name := _extract_music_name(file_name)
			bgm_library[music_name] = full_path

		file_name = dir.get_next()

	dir.list_dir_end()


func _extract_music_name(file_name: String) -> String:
	# 去掉 .mp3 扩展名
	var name_without_ext := file_name.rstrip(".mp3")

	# 按 " - " 分割，取最后一部分作为音乐名称
	var parts := name_without_ext.split(" - ")
	if parts.size() > 1:
		return parts[-1].strip_edges()

	# 如果没有 " - " 分隔符，返回整个文件名（去掉扩展名）
	return name_without_ext.strip_edges()


## 获取所有音乐名称列表
func get_all_music_names() -> Array[String]:
	var names: Array[String] = []
	for name in bgm_library.keys():
		names.append(name)
	return names

## 根据音乐名称获取文件路径
func get_music_path(music_name: String) -> String:
	return bgm_library.get(music_name, "")

## 打印所有音乐信息（调试用）
func print_bgm_library() -> void:
	print("=== 背景音乐库 ===")
	for music_name in bgm_library:
		print("名称: %s -> 文件: %s" % [music_name, bgm_library[music_name]])
	print("共 %d 首音乐" % bgm_library.size())
	
func load_bgm_stream(music_path: String) -> AudioStream:
	return load(music_path) as AudioStream

## 从音乐库中随机选择一个音乐并返回 AudioStream
func get_random_bgm() -> AudioStream:
	if bgm_library.is_empty():
		return null

	var keys = bgm_library.keys()
	var random_key = keys[randi() % keys.size()]
	var random_path: String = bgm_library[random_key]

	return load(random_path) as AudioStream
