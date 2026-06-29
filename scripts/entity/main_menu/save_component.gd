extends Control
class_name SaveComponent

@onready var info: UserInfo = UserInfo.new()
func use_info(_info: UserInfo) -> void:
	info = _info

@onready var label: Label = $Label

func _process(delta: float) -> void:
	if info != null:
		label.text = info.get_description()

signal button_up
func _on_button_button_up() -> void:
	button_up.emit()
