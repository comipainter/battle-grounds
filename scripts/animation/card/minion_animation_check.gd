class_name MinionAnimationCheck

static func check_coin_increase(cardList: Array[Card], coinIncrease: int) -> void:
	for card in cardList:
		coin_increase(card, coinIncrease)
		
static func check_coin_decrease(cardList: Array[Card], coinDecrease: int) -> void:
	for card in cardList:
		coin_decrease(card, coinDecrease)

static func check_buy(cardList: Array[Card], buyCard: Card) -> void:
	for card in cardList:
		buy(card, buyCard)
		
static func check_sell(cardList: Array[Card]) -> void:
	for card in cardList:
		sell(card)
		
static func check_revenge(cardList: Array[Card], dieMinion: Minion) -> void:
	for card in cardList:
		var minion: Minion = card
		if minion.get_uniqueId() == dieMinion.get_uniqueId():
			continue
		revenge(minion)
		
static func check_add_hand(cardList: Array[Card], addCard: Card) -> void:
	for card in cardList:
		add_hand(card, addCard)
		
static func check_use_magic(cardList: Array[Card]) -> void:
	for card in cardList:
		use_magic(card)
		
static func check_round_start(cardList: Array[Card]) -> void:
	for card in cardList:
		round_start(card)

# 金币数量增加
static func coin_increase(minion: Minion, coinIncrease: int) -> void:
	match minion.get_cardName():
		"夺金健将":
			minion.add_animation(MinionAnimation.DuoJinJianJiang.new(minion))
		"开挂荷官":
			minion.add_animation(MinionAnimation.KaiGuaHeGuan.new(minion, coinIncrease))

# 金币数量减少
static func coin_decrease(minion: Minion, coinDecrease: int) -> void:
	match minion.get_cardName():
		"火药运输工":
			minion.add_effectCount(coinDecrease)
		"舰队上将":
			minion.add_effectCount(coinDecrease)

# 购买
static func buy(minion: Minion, buyCard: Card) -> void:
	match minion.get_cardName():
		"咒缚海员":
			if buyCard.is_minion():
				minion.add_effectCount(1)

# 出售
static func sell(minion: Minion) -> void:
	match minion.get_cardName():
		"白赚赌徒":
			minion.add_animation(MinionAnimation.BaiZhuanDutu.new())

# 亡语
static func die(minion: Minion) -> void:
	match minion.get_cardName():
		"海上走私贩":
			minion.add_animation(MinionAnimation.HaiShangZouSiFan.new(minion))

# 复仇
static func revenge(minion: Minion) -> void:
	match minion.get_cardName():
		"托尼双牙":
			minion.add_effectCount(1)
			
# 置入手牌
static func add_hand(minion: Minion, addCard: Card) -> void:
	match minion.get_cardName():
		"练腿":
			# 随机选择场上另两个友方随从
			if GameManager.is_shopping():
				var deskMinionList = GameManager.shopScene.deskCardList.duplicate(true)
				deskMinionList.shuffle()
				deskMinionList.erase(minion)
				var minionList: Array[Card]
				if deskMinionList.size() > 2:
					minionList = [deskMinionList[0], deskMinionList[1]]
				else:
					minionList = deskMinionList
				for minionInList in minionList:
					minionInList.add_animation(MinionAnimation.LianTui.new(minionInList))
		"德鲁斯特":
			if addCard.is_minion():
				var addMinion: Minion = addCard
				if addMinion.get_race() == "海盗":
					if GameManager.is_shopping():
						for card in GameManager.shopScene.deskCardList:
							var targetMinion: Minion = card
							card.add_animation(MinionAnimation.DeLuSiTe.new(card))
		
# 上场（战吼）
static func use(minion: Minion) -> void:
	match minion.get_cardName():
		"格蕾丝法希尔":
			minion.add_animation(MinionAnimation.GeLeiSiFaXiEr.new())
		"顽砂猎头":
			minion.add_animation(MinionAnimation.WanShaLieTou.new(minion))
		"火药运输工":
			minion.create_effectCount(0, 5, func(paramSelf):
				if GameManager.is_shopping():
					for card in GameManager.shopScene.deskCardList:
						card.add_animation(MinionAnimation.HuoYaoYunShuGong.new(card))
				)
		"咒缚海员":
			minion.create_effectCount(0, 3, func(paramSelf):
				paramSelf.add_animation(MinionAnimation.ZhouFuHaiYuan.new(paramSelf))
				)
		"精英导航员":
			minion.add_animation(MinionAnimation.JinYingDaoHangYuan.new(minion))
		"舰队上将":
			minion.create_effectCount(0, 9, func(paramSelf):
				paramSelf.add_animation(MinionAnimation.JianDuiShangJiang.new(paramSelf))
				)
		"托尼双牙":
			minion.create_effectCount(0, 1, func(paramSelf):
				paramSelf.add_animation(MinionAnimation.TuoNiShuangYa.new(paramSelf))
				)
		
# 使用法术
static func use_magic(minion: Minion) -> void:
	match minion.get_cardName():
		"时空船长钩尾":
			if GameManager.is_shopping():
				for card in GameManager.shopScene.deskCardList:
					card.add_animation(MinionAnimation.ShiKongChuanZhangGouWei.new(card))

# 进击
static func attack(attackMinion: Minion, behitMinion: Minion) -> void:
	match attackMinion.get_cardName():
		"刀剑收藏家":
			attackMinion.add_animation(MinionAnimation.DaoJianShouCangJia.new(attackMinion, behitMinion))

# 回合开始
static func round_start(minion: Minion) -> void:
	match minion.get_cardName():
		"偷金捣蛋鬼":
			minion.add_animation(MinionAnimation.TouJinDaoDanGui.new())
