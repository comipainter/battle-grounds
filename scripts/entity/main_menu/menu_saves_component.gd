extends Control
class_name ManuSavesComponent

@onready var saveListComponent: SaveListComponent = $SaveList
@onready var saveInfoDisplayComponent: MenuSaveInfoDisplayComponent = $SaveInfoDisplay
@onready var loadButton: Button = $LoadButton
@onready var loadLabel: Label = $LoadLabel
@onready var backgroundPanel: Panel = $BackgroundPanel
@onready var exitButton: Button = $ExitButton
@onready var exitLabel: Label = $ExitLabel

func _ready() -> void:
	saveListComponent.save_button_up.connect(
		func(info: UserInfo):
			saveInfoDisplayComponent.use_info(info)
	)

func start() -> void:
	set_able(true)
	saveListComponent.start()
	saveInfoDisplayComponent.start()

func set_able(_able: bool) -> void:
	saveListComponent.set_able(_able)
	saveInfoDisplayComponent.set_able(_able)
	loadButton.visible = _able
	loadLabel.visible = _able
	exitButton.visible = _able
	exitLabel.visible = _able
	backgroundPanel.visible = _able

signal exited
func _on_exit_button_button_up() -> void:
	exited.emit()
	
signal load_save_selected
func _on_load_button_button_up() -> void:
	var info: UserInfo = saveInfoDisplayComponent.get_curr_info()
	if info != null:
		load_save_selected.emit(info)
