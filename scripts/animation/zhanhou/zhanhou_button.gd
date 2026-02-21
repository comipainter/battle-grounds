extends Control

class_name ZhanhouButton

@export var button: Button

var target: Control

func _process(delta: float) -> void:
	self.global_position = target.global_position
