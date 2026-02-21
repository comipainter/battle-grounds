class_name AddInfo

func _init(attack, health) -> void:
	self.attack = attack
	self.health = health

var attack: int
var health: int

func get_attack() -> int:
	return self.attack
func get_health() -> int:
	return self.health
