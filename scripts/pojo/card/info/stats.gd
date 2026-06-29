extends Resource
class_name Stats

@export var attack: int
@export var health: int

func _init(attack = 1, health = 1) -> void:
	self.attack = attack
	self.health = health

func set_attack(_attack: int) -> void:
	attack = _attack
func set_health(_health: int) -> void:
	health = _health
func get_attack() -> int:
	return self.attack
func get_health() -> int:
	return self.health

func set_stats(stats: Stats) -> void:
	attack = stats.attack
	health = stats.health
func add_stats(stats: Stats) -> void:
	attack += stats.attack
	health += stats.health
func sub_stats(stats: Stats) -> void:
	attack -= stats.attack
	health -= stats.health
func mul_stats(mul: int) -> void:
	attack *= mul
	health *= mul
