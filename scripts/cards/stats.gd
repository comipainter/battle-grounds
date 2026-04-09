class_name Stats

func _init(attack, health) -> void:
	self.attack = attack
	self.health = health

var attack: int
var health: int

func get_attack() -> int:
	return self.attack
func get_health() -> int:
	return self.health

static func add_stats(stats1: Stats, stats2: Stats) -> Stats:
	return Stats.new(stats1.attack + stats2.attack, stats1.health + stats2.health)

static func double(stats: Stats) -> Stats:
	return Stats.new(stats.attack*2, stats.health*2)
