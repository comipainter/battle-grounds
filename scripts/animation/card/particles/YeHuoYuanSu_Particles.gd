extends Control
@export var particles: GPUParticles2D

var startPosition: Vector2 = Vector2(0, 0)
var explodePosition: Vector2 = Vector2(500, 500)

var time: float = 0.5

var particlesMaterial: ParticleProcessMaterial
func _ready() -> void:
	particlesMaterial = particles.process_material
	emit()

func emit() -> void:
	var direction := (explodePosition - startPosition)
	var distance := direction.length()
	direction = direction.normalized()
	particlesMaterial.direction = Vector3(direction.x, direction.y, 0)
	particlesMaterial.initial_velocity_min = distance / time
	particlesMaterial.initial_velocity_max = distance / time
	particles.emitting = true
