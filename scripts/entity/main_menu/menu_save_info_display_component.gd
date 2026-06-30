extends Control
class_name MenuSaveInfoDisplayComponent

@onready var container: VBoxContainer = $Panel/ScrollContainer/VBoxContainer

func start() -> void:
	set_able(true)

func set_able(_able) -> void:
	self.visible = _able
	
var _curr_info: UserInfo
func get_curr_info() -> UserInfo:
	return _curr_info
	
func use_info(info: UserInfo) -> void:
	if _curr_info == info:
		return
	else:
		_curr_info = info
	# 清空现有展示
	_clear_all_children()
	# 检查本地存档
	# 检查文件夹下的所有文档
	for dir_path in DirAccess.get_directories_at(PathUtils.get_user_info_dir(info)):
		var gameData: GameData = load(PathUtils.get_user_info_dir(info) + dir_path + "/game_data.tres")
		var gameDataDisplay: GameDataDisplay = DataManager.gameDataDisplayScene.instantiate()
		container.add_child(gameDataDisplay)
		gameDataDisplay.use_data(gameData)

func _clear_all_children():
	while container.get_child_count() > 0:
		container.get_child(0).free()
