extends Control

@export var contentContainer: VBoxContainer

func _ready() -> void:
	_setup_bgm_list()

## 设置背景音乐列表
func _setup_bgm_list() -> void:
	# 清空现有内容
	for child in contentContainer.get_children():
		child.queue_free()

	# 获取所有音乐名称
	var music_names := GameManager.bgmAsset.get_all_music_names()

	for music_name in music_names:
		# 创建 Control 作为 VBoxContainer 占位
		var container := Control.new()
		container.custom_minimum_size = Vector2(0, 100)

		# 创建 Button
		var button := Button.new()
		button.text = ">>>"
		button.position = Vector2(10, 5)
		button.custom_minimum_size = Vector2(60, 30)
		button.add_theme_font_size_override("font_size", 40)

		# 绑定按钮点击事件
		var path := GameManager.bgmAsset.get_music_path(music_name)
		button.pressed.connect(_on_bgm_button_pressed.bind(path))

		# 创建 Label
		var label := Label.new()
		label.text = music_name
		label.position = Vector2(130, 10)
		label.size = Vector2(200, 20)
		label.add_theme_font_size_override("font_size", 40)

		# 添加子节点
		container.add_child(button)
		container.add_child(label)
		contentContainer.add_child(container)

## 背景音乐按钮点击回调
func _on_bgm_button_pressed(music_path: String) -> void:
	if music_path == "":
		return
	GameManager.play_bgm(GameManager.bgmAsset.load_bgm_stream(music_path))

func _on_end_button_button_down() -> void:
	self.queue_free()
