extends CardData
class_name MinionData

func copy() -> MinionData:
	return duplicate(true)

@export var attack: int
@export var health: int
func get_attack() -> int:
	return attack
func get_health() -> int:
	return health
func get_stats() -> Stats:
	return Stats.new(attack, health)
	
@export var goldenDescription: String
func get_goldenDescription() -> String:
	return goldenDescription

@export var race: Race.Type = Race.Type.None
func get_race() -> Race.Type:
	return race

@export var shengdun: bool
func get_shengdun() -> bool:
	return shengdun
	
@export var liedu: bool
func get_liedu() -> bool:
	return liedu

@export var fusheng: bool
func get_fusheng() -> bool:
	return fusheng
	
@export var chaofeng: bool
func get_chaofeng() -> bool:
	return chaofeng

@export var fengnu: bool
func get_fengnu() -> bool:
	return fengnu

@export var cili: bool = false
func is_cili() -> bool:
	return cili
func set_cili(_cili: bool) -> void:
	cili = _cili
