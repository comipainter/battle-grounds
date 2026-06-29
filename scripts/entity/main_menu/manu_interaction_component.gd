extends Control
class_name MenuInteractionComponent

func set_able(_able: bool) -> void:
	self.visible = _able

func start() -> void:
	set_able(true)
	
func close() -> void:
	set_able(false)

signal start_button_up
func _on_start_button_button_up() -> void:
	start_button_up.emit()

signal save_button_up
func _on_save_button_button_up() -> void:
	save_button_up.emit()
