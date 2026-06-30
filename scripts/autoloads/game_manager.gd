extends Control

var mainScene: MainScene
func get_main_scene() -> MainScene:
	return mainScene
signal main_scene_registered(_mainScene: MainScene)
func set_main_scene(_mainScene: MainScene) -> void:
	mainScene = _mainScene
	mainScene.game_overed.connect(
		_change_to_main_menu
	)
	main_scene_registered.emit(mainScene)
	
var mainMenu: MainMenu
func get_main_menu() -> MainMenu:
	return mainMenu
func set_main_menu(_mainMenu: MainMenu) -> void:
	mainMenu = _mainMenu
	mainMenu.game_started.connect(_change_to_main_scene)
	mainMenu.game_started_with_save.connect(_change_to_main_scene)

@onready var inputManager: InputManager = $InputManager
func get_input_manager() -> InputManager:
	return inputManager

func _ready() -> void:
	_change_to_main_menu()

func _change_to_main_scene() -> void:
	if get_tree():
		DataManager.reset()
		get_tree().change_scene_to_file(Path.ScenePath.MAIN_SCENE)
	else:
		printerr("无法获取场景树，请检查项目主场景设置！")
		
func _change_to_main_menu() -> void:
	if get_tree():
		DataManager.reset()
		get_tree().change_scene_to_file(Path.ScenePath.MAIN_MENU)
	else:
		printerr("无法获取场景树，请检查项目主场景设置！")
