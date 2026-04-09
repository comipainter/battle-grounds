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
	if cardData["shengdun"] == "1":
		shengdun = true
	if cardData["liedu"] == "1":
		liedu = true
	if cardData["fusheng"] == "1":
		fusheng = true
	if cardData["chaofeng"] == "1":
		chaofeng = true
	if cardData["fengnu"] == "1":
		fengnu = true
	super._init(cardData)
	
var uniqueId: int

var attack: int
var health: int

var originStats: Stats = Stats.new(0, 0)
func get_originStats() -> Stats:
	if originStats.attack == 0 and originStats.health == 0:
		if is_ronghe():
			for baseMinionInfo in baseMinionInfoList:
				originStats = Stats.add_stats(originStats, baseMinionInfo.get_originStats())
		else:
			originStats = MinionData.get_minion_by_id(GameManager.allMinionInfo, id).get_stats()
	return originStats

var race: String

var golden: bool

var shengdun: bool = false
var liedu: bool = false
var fusheng: bool = false
var chaofeng: bool = false
var fengnu: bool = false

var minionEffectList: MinionEffectList = MinionEffectList.new()

# 融合组件随从信息
var baseMinionInfoList: Array[MinionInfo] = []
func add_baseMinionInfo(minionInfo: MinionInfo) -> void:
	baseMinionInfoList.append(minionInfo)
	minionInfo.be_ronghe = true
	minionInfo.rongheMinionInfo = self
func get_baseMinionInfoList() -> Array[MinionInfo]:
	return baseMinionInfoList
func is_ronghe() -> bool:
	return !baseMinionInfoList.is_empty()
	
var be_ronghe: bool = false
func is_be_ronghe() -> bool:
	return be_ronghe
var rongheMinionInfo: MinionInfo

var effectCountAble: bool = false
var effectCount: int = 0
var effectCountLimit: int = 1
var effectCountFunction: Callable = func(): 
	pass

var boostCountAble: bool = false
var boostCount: int = 0

var clockAble: bool = false
var clockRoundTime: int = 1
var clockFunction: Callable = func(): 
	pass
	
var clickAble: bool = false
var clickIdle: bool = false
var clickSpritePath: String = ""
var clickSpriteScale: Vector2 = Vector2(1, 1)
var clickSpriteFunction: Callable = func(): 
	pass
var clickFunction: Callable = func(): 
	pass
	
func create() -> MinionInfo:
	var copy: MinionInfo = duplicate()
	copy.uniqueId = GameManager.get_uniqueId()
	if is_ronghe():
		copy.baseMinionInfoList = []
		for baseMinionInfo in baseMinionInfoList:
			copy.add_baseMinionInfo(baseMinionInfo.create())
	return copy

func duplicate() -> MinionInfo:
	var copy = MinionInfo.new(_to_dict())
	copy.uniqueId = uniqueId
	copy.golden = golden
	
	copy.minionEffectList = minionEffectList.duplicate()
	
	copy.be_ronghe = be_ronghe
	if is_ronghe():
		for baseMinionInfo in baseMinionInfoList:
			copy.add_baseMinionInfo(baseMinionInfo.duplicate())
	else:
		copy.rongheMinionInfo = rongheMinionInfo
	
	copy.effectCountAble = effectCountAble
	copy.effectCount = effectCount
	copy.effectCountLimit = effectCountLimit
	copy.effectCountFunction = effectCountFunction
	
	copy.boostCount = boostCount
	copy.boostCountAble = boostCountAble
	
	copy.clockAble = clockAble
	copy.clockRoundTime = clockRoundTime
	copy.clockFunction = clockFunction
	
	copy.clickAble = clickAble
	copy.clickFunction = clickFunction
	copy.clickSpritePath = clickSpritePath
	copy.clickSpriteScale = clickSpriteScale
	copy.clickSpriteFunction = clickSpriteFunction
	copy.clickIdle = clickIdle
	return copy

func _to_dict() -> Dictionary:
	var dict: Dictionary = super._to_dict()
	dict["attack"] = attack
	dict["health"] = health
	dict["race"] = race
	dict["shengdun"] = str(int(shengdun))
	dict["liedu"] = str(int(liedu))
	dict["fusheng"] = str(int(fusheng))
	dict["chaofeng"] = str(int(chaofeng))
	dict["fengnu"] = str(int(fengnu))
	return dict

func set_golden(gold: bool) -> void:
	if golden == true:
		return 
	golden = gold
	var originInfo: MinionInfo = MinionData.get_minion_by_id(GameManager.allMinionInfo, id)
	attack += originInfo.attack
	health += originInfo.health

func add_stats(addStats: Stats) -> void:
	attack += addStats.get_attack()
	health += addStats.get_health()
	if is_be_ronghe():
		rongheMinionInfo.add_stats(addStats)
	
func get_stats() -> Stats:
	return Stats.new(attack, health)
	
func set_stats(stats: Stats) -> void:
	attack = stats.get_attack()
	health = stats.get_health()

static func create_ronghe(minionInfo1: MinionInfo, minionInfo2: MinionInfo) -> MinionInfo:
	# 融合创建新名字
	var newNameArray: Array = (minionInfo1.name + minionInfo2.name).split("")
	newNameArray.shuffle()
	var newName: String = "".join(newNameArray)
	newName = newName.substr(0, int(newName.length()/2))
	# 先创建融合样本
	var newInfo: MinionInfo = MinionInfo.new({
		"id": -1,
		"level": int((minionInfo1.level + minionInfo2.level)/2),
		"name": newName,
		"race": [minionInfo1.race, minionInfo2.race].pick_random(),
		"attack": 0,
		"health": 0,
		"description": "力量的形态千变万化",
		"sellable": str(0),
		"shengdun": str(int(minionInfo1.shengdun or minionInfo2.shengdun)),
		"liedu": str(int(minionInfo1.liedu or minionInfo2.liedu)),
		"fusheng": str(int(minionInfo1.fusheng or minionInfo2.fusheng)),
		"chaofeng": str(int(minionInfo1.chaofeng or minionInfo2.chaofeng)),
		"fengnu": str(int(minionInfo1.fengnu or minionInfo2.fengnu)),
		"type": "minion",
		"golden": 0,
		"sprite_path": ""
	})
	for baseMinionInfo in minionInfo1.baseMinionInfoList + minionInfo2.baseMinionInfoList:
		newInfo.add_baseMinionInfo(baseMinionInfo)
	if not minionInfo1.is_ronghe():
		newInfo.add_baseMinionInfo(minionInfo1)
	if not minionInfo2.is_ronghe():
		newInfo.add_baseMinionInfo(minionInfo2)
	for effect in minionInfo1.minionEffectList.effectList + minionInfo2.minionEffectList.effectList:
		newInfo.minionEffectList.add_effect(effect)
	newInfo.set_stats(newInfo.get_originStats())
	return newInfo
