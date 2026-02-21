extends Node2D

class_name MainMenu

func _ready() -> void:
	GameManager.mainMenu = self

func _on_start_game_button_button_up() -> void:
	GameManager.end_menu()
