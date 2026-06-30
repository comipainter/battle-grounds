extends Control
class_name ZhanhouButton

@onready var button: Button = $Button

@onready var vfx: ColorRect = $ColorRect

var target: Minion

signal button_up
func _on_button_button_up() -> void:
	button_up.emit()

func _process(delta: float) -> void:
	if is_instance_valid(target):
		self.global_position = target.global_position
