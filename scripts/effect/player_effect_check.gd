class_name PlayerEffectCheck

static func free_fresh() -> bool:
	for effect in GameManager.playerEffectList.get_list():
		match effect.name:
			"免费刷新":
				effect.execute()
				return true
	return false
	
static func check_free_fresh() -> bool:
	for effect in GameManager.playerEffectList.get_list():
		match effect.name:
			"免费刷新":
				return effect.check()
	return false

static func more_fresh() -> Array[CardInfo]:
	var cardList: Array[CardInfo] = []
	for effect in GameManager.playerEffectList.get_list():
		match effect.name:
			"刷新后提供额外的随从":
				cardList = cardList + effect.execute()
	return cardList
	
# 回合开始
static func round_start() -> void:
	for effect in GameManager.playerEffectList.get_list():
		match effect.name:
			"使用元素卡牌":
				effect.round_start()
				
# 使用卡牌
static func use(card: Card) -> void:
	for effect in GameManager.playerEffectList.get_list():
		match effect.name:
			"使用元素卡牌":
				if card.is_minion() == true:
					var minion: Minion = card
					if minion.get_race().contains("元素"):
						effect.add_value(1)
						
# 查找效果
static func find_effect(effect: PlayerEffect) -> PlayerEffect:
	for effectInList in GameManager.playerEffectList.get_list():
		if effectInList.name == effect.name:
			return effectInList
	return null
