extends Control
class_name MainMenu

@onready var interactionComponent: MenuInteractionComponent = $Interaction
func get_interaction_component() -> MenuInteractionComponent:
	return interactionComponent
	
@onready var savesComponent: ManuSavesComponent = $Saves
func get_saves_component() -> ManuSavesComponent:
	return savesComponent

signal game_started
signal game_started_with_save(info: UserInfo)
func _ready() -> void:
	GameManager.set_main_menu(self)
	get_interaction_component().start_button_up.connect(
		func():
			game_started.emit()
	)
	get_interaction_component().save_button_up.connect(
		func():
			get_interaction_component().set_able(false)
			get_saves_component().start()
	)
	get_saves_component().load_save_selected.connect(
		func(_info: UserInfo):
			game_started_with_save.emit(_info)
	)
	get_saves_component().exited.connect(
		func():
			get_interaction_component().start()
			get_saves_component().set_able(false)
	)
	
	get_interaction_component().start()
	get_saves_component().set_able(false)
