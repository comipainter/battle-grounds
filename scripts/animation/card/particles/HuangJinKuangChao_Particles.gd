extends Control

class_name HuangJinKuangChao_Particles

@export var travelParticles: GPUParticles2D
@export var explodeParticles: GPUParticles2D

var startPosition: Vector2 = Vector2(0, 0)
var explodePosition: Vector2 = Vector2(500, 500)

var time: float = 0.5
var emitting: bool = false
var travelParticlesMaterial: ParticleProcessMaterial

func _ready() -> void:
	travelParticlesMaterial = travelParticles.process_material.duplicate(true)
	travelParticles.process_material = travelParticlesMaterial
	
func _process(delta: float) -> void:
	if emitting == true:
		emitting = false
		travel()
		await get_tree().create_timer(0.5).timeout
		explode()
		
	
func travel() -> void:
	print("travel")
	travelParticles.global_position = startPosition
	var direction := (explodePosition - startPosition)
	var distance := direction.length()
	direction = direction.normalized()
	travelParticlesMaterial.direction = Vector3(direction.x, direction.y, 0)
	travelParticlesMaterial.initial_velocity_min = distance / time
	travelParticlesMaterial.initial_velocity_max = distance / time
	
	travelParticles.set_lifetime(time)
	travelParticles.emitting = true
	print(travelParticles)
	
func explode() -> void:
	explodeParticles.global_position = explodePosition
	explodeParticles.emitting = true
