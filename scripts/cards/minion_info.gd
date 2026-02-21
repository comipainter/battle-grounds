extends CardInfo
class_name MinionInfo

func _init(cardData: Dictionary) -> void:
	if cardData.has("golden"):
		if cardData["golden"] == 0:
			golden = false
		else:
			golden = true
	effectCountAble = false
	attack = cardData["attack"]
	health = cardData["health"]
	race = cardData["race"]
	super._init(cardData)
	
var uniqueId: int

var attack: int
var health: int
var race: String

var golden: bool

var effectCountAble: bool
var effectCount: int
var maxEffectCount: int
var effectCountFunction: Callable

func create() -> MinionInfo:
	var copy: MinionInfo = duplicate()
	copy.uniqueId = GameManager.get_uniqueId()
	return copy

func duplicate() -> MinionInfo:
	var copy = MinionInfo.new(_to_dict())
	copy.uniqueId = uniqueId
	copy.golden = golden
	copy.effectCountAble = effectCountAble
	copy.effectCount = effectCount
	copy.maxEffectCount = maxEffectCount
	copy.effectCountFunction = effectCountFunction
	return copy

func _to_dict() -> Dictionary:
	var dict: Dictionary = super._to_dict()
	dict["attack"] = attack
	dict["health"] = health
	dict["race"] = race
	return dict

func set_golden(gold: bool) -> void:
	if golden == true:
		return 
	golden = gold
	var originInfo: MinionInfo = MinionData.get_minion_by_id(id)
	attack += originInfo.attack
	health += originInfo.health
