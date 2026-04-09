extends Control

class_name LuoShuLongGuFan_Particles

@export var particles: GPUParticles2D

var clicked: bool = false

func is_clicked() -> bool:
	return clicked

func click() -> void:
	clicked = true
	particles.emitting = false
