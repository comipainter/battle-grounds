extends Node2D

class_name MainMenu

func _ready() -> void:
	GameManager.mainMenu = self
	GameManager.play_bgm(GameManager.bgmAsset.get_random_bgm())

func _on_start_game_button_button_up() -> void:
	GameManager.end_menu()

func _on_settings_button_button_down() -> void:
	var settings = load("res://scenes/settings.tscn").instantiate()
	add_child(settings)
