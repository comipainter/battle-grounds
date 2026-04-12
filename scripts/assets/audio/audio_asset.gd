class_name AudioAsset

# 第一次进入商店
var shopSceneStart1 = preload("res://assets/audio/ShopSceneStart1.ogg")
var shopSceneStart2 = preload("res://assets/audio/ShopSceneStart2.ogg")
var shopSceneStart: Array = [
	shopSceneStart1,
	shopSceneStart2
]
func get_shopSceneStart() -> AudioStream:
	return shopSceneStart.pick_random()

# 开始战斗
var fightSceneStart1 = preload("res://assets/audio/fightSceneStart1.ogg")
var fightSceneStart2 = preload("res://assets/audio/fightSceneStart2.ogg")
var fightSceneStart3 = preload("res://assets/audio/fightSceneStart3.ogg")
var fightSceneStart4 = preload("res://assets/audio/fightSceneStart4.ogg")
var fightSceneStart5 = preload("res://assets/audio/fightSceneStart5.ogg")
var fightSceneStart: Array = [
	fightSceneStart1,
	fightSceneStart2,
	fightSceneStart3,
	fightSceneStart4,
	fightSceneStart5
]
func get_fightSceneStart() -> AudioStream:
	return fightSceneStart.pick_random()
	
# 战斗失败返回商店
var fightDefeat1 = preload("res://assets/audio/fightDefeat1.ogg")
var fightDefeat2 = preload("res://assets/audio/fightDefeat2.ogg")
var fightDefeat3 = preload("res://assets/audio/fightDefeat3.ogg")
var fightDefeat: Array = [
	fightDefeat1,
	fightDefeat2,
	fightDefeat3
]
func get_fightDefeat() -> AudioStream:
	return fightDefeat.pick_random()
	
# 战斗胜利返回商店
var fightVictory1 = preload("res://assets/audio/fightDefeat1.ogg")
var fightVictory2 = preload("res://assets/audio/fightDefeat2.ogg")
var fightVictory3 = preload("res://assets/audio/fightDefeat3.ogg")
var fightVictory: Array = [
	fightVictory1,
	fightVictory2,
	fightVictory3
]
func get_fightVictory() -> AudioStream:
	return fightVictory.pick_random()
	
# 战斗平局返回商店
var fightDraw1 = preload("res://assets/audio/fightDraw1.ogg")
var fightDraw2 = preload("res://assets/audio/fightDraw2.ogg")
var fightDraw3 = preload("res://assets/audio/fightDraw3.ogg")
var fightDraw: Array = [
	fightDraw1,
	fightDraw2,
	fightDraw3
]
func get_fightDraw() -> AudioStream:
	return fightDraw.pick_random()

# 购买随从
var buySmallMinion1 = preload("res://assets/audio/buySmallMinion1.ogg")
var buySmallMinion2 = preload("res://assets/audio/buySmallMinion2.ogg")
var buySmallMinion3 = preload("res://assets/audio/buySmallMinion3.ogg")
var buyMiddleMinion1 = preload("res://assets/audio/buyMiddleMinion1.ogg")
var buyMiddleMinion2 = preload("res://assets/audio/buyMiddleMinion2.ogg")
var buyMiddleMinion3 = preload("res://assets/audio/buyMiddleMinion3.ogg")
var buyLargeMinion1 = preload("res://assets/audio/buyLargeMinion1.ogg")
var buyLargeMinion2 = preload("res://assets/audio/buyLargeMinion2.ogg")
var buyLargeMinion3 = preload("res://assets/audio/buyLargeMinion3.ogg")
var buySmallMinion: Array = [
	buySmallMinion1,
	buySmallMinion2,
	buySmallMinion3
]
var buyMiddleMinion: Array = [
	buyMiddleMinion1,
	buyMiddleMinion2,
	buyMiddleMinion3
]
var buyLargeMinion: Array = [
	buyLargeMinion1,
	buyLargeMinion2,
	buyLargeMinion3
]
func get_buyMinion(info: MinionInfo) -> AudioStream:
	if info.level <= 2:
		return buySmallMinion.pick_random()
	elif info.level >= 3 and info.level <= 4:
		return buyMiddleMinion.pick_random()
	else:
		return buyLargeMinion.pick_random()
		
# 出售随从
var sellMinion1 = preload("res://assets/audio/sellMinion1.ogg")
var sellMinion2 = preload("res://assets/audio/sellMinion2.ogg")
var sellMinion: Array = [
	sellMinion1,
	sellMinion2
]
func get_sellMinion() -> AudioStream:
	return sellMinion.pick_random()
	
# 升级酒馆
var shopLevelUp1 = preload("res://assets/audio/shopLevelUp1.ogg")
var shopLevelUp2 = preload("res://assets/audio/shopLevelUp2.ogg")
var shopLevelUp3 = preload("res://assets/audio/shopLevelUp3.ogg")
var shopLevelUp4 = preload("res://assets/audio/shopLevelUp4.ogg")
var shopLevelUp: Array = [
	shopLevelUp1,
	shopLevelUp2,
	shopLevelUp3,
	shopLevelUp4
]
func get_shopLevelUp() -> AudioStream:
	return shopLevelUp.pick_random()
	
# 使用随从
func use_minion(info: MinionInfo) -> AudioStream:
	var path := "res://assets/audio/minion/" + info.name + ".ogg"
	if ResourceLoader.exists(path):
		return load(path)
	return null

# 随从攻击
func minion_attack(info: MinionInfo) -> AudioStream:
	var path := "res://assets/audio/minion/" + info.name + " (2).ogg"
	if ResourceLoader.exists(path):
		return load(path)
	return null

# 随从死亡
func minion_die(info: MinionInfo) -> AudioStream:
	var path := "res://assets/audio/minion/" + info.name + " (3).ogg"
	if ResourceLoader.exists(path):
		return load(path)
	return null
