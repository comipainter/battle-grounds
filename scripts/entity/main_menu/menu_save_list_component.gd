extends Control
class_name SaveListComponent

@onready var container: VBoxContainer = $VBoxContainer

func set_able(_able: bool) -> void:
	if _able == false:
		_clear_all_children()
	self.visible = _able

signal save_button_up(userInfo: UserInfo)
func start() -> void:
	# 清空现有展示
	_clear_all_children()
	# 检查本地存档
	# 检查文件夹下的所有文档
	for dir_path in DirAccess.get_directories_at(Path.SavePath.Base):
		var userInfo: UserInfo = load(Path.SavePath.Base + dir_path + "/user_info.tres")
		var saveComponent: SaveComponent = DataManager.saveScene.instantiate()
		container.add_child(saveComponent)
		saveComponent.use_info(userInfo)
		saveComponent.button_up.connect(
			func():
				save_button_up.emit(userInfo)
		)
	

func _clear_all_children():
	while container.get_child_count() > 0:
		container.get_child(0).queue_free()
