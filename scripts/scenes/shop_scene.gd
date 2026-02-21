extends Node2D

class_name ShopScene

# 金币相关
var coinRest: int = 0
var coinLimit: int = 0

# 卡牌相关
var deskCardList: Array[Card] = []
var handCardList: Array[Card] = []
var shopCardList: Array[Card] = []

func end() -> void:
	var deskInfoList: Array[CardInfo] = []
	for card in deskCardList:
		deskInfoList.append(card.get_info().duplicate())
	var handInfoList: Array[CardInfo] = []
	for card in handCardList:
		handInfoList.append(card.get_info().duplicate())
	GameManager.deskCardInfoList = deskInfoList.duplicate(true)
	GameManager.handCardInfoList = handInfoList.duplicate(true)
	GameManager.end_shop()
	
func fresh() -> void:
	sub_coin(1)
	for card in shopCardList.duplicate(true):
		delete_shopCard(card)
	var shopCardInfoList = generate_shopCardInfoList()
	for info in shopCardInfoList:
		create_shopCard(info, shopPosition)

func levelUp() -> void:
	if GameManager.shopLevel < GameManager.shopLevelCost.size():
		if coinRest >= GameManager.shopLevelCost[GameManager.shopLevel]:
			sub_coin(GameManager.shopLevelCost[GameManager.shopLevel])
			GameManager.shopLevel += 1
			display_level()
	
func buy(card: Card) -> void:
	if (card.is_minion() and coinRest < 3) or\
	(card.is_magic() and coinRest < card.get_cost()):
		print("购买失败")
	else:
		if card.is_minion():
			sub_coin(3)
		else:
			sub_coin(card.get_cost())
		MinionAnimationCheck.check_buy(deskCardList, card)
		remove_shopCard(card)
		add_handCard(card)
		add_card_tripleCheckList(card)

func use(card: Card) -> void:
	remove_handCard(card)
	if card.is_minion():
		add_deskCard(card)
		MinionAnimationCheck.use(card)
	else:
		MagicAnimationCheck.use(card)
		MinionAnimationCheck.check_use_magic(deskCardList)
	
func sell(card: Card) -> void:
	add_coin(1)
	MinionAnimationCheck.sell(card)
	card.add_animation(MinionAnimation.RemoveAnimation.new(card))
	sub_card_tripleCheckList(card)

# 金币相关
func add_coin(num: int) -> void:
	#if coinRest < coinLimit:
	coinRest += num
	#if coinRest > coinLimit:
		#coinRest = coinLimit
	MinionAnimationCheck.check_coin_increase(deskCardList, num)
	display_coin()

func sub_coin(num: int) -> void:
	coinRest -= num
	MinionAnimationCheck.check_coin_decrease(deskCardList, num)
	display_coin()

# 节点相关

@export var handCardContainer: HBoxContainer
@export var deskCardContainer: HBoxContainer
@export var shopCardContainer: HBoxContainer
@export var cardFatherNode: Control

@export var handPosition: Vector2
@export var deskPosition: Vector2
@export var shopPosition: Vector2

@export var choose: Control

# 分离参数
var separationSize: int = 250

@export var levelUpCostLabel: Label
func display_levelUp() -> void:
	levelUpCostLabel.text = str(GameManager.shopLevelCost[GameManager.shopLevel])

@export var freshCostLabel: Label
func display_fresh() -> void:
	freshCostLabel.text = str(1)

@export var coinLabel: Label
func display_coin() -> void:
	coinLabel.text = str(coinRest) + " / " + str(coinLimit)

@export var levelSprite: Sprite2D
func display_level() -> void:
	levelSprite.texture = GameManager.levelSpriteTemplate[GameManager.shopLevel]
	levelSprite.scale = GameManager.levelSpriteScale[GameManager.shopLevel]*2
	
@export var bugRegionNode: Control
@export var deskRegionNode: Control
@export var sellRegionNode: Control
func is_in_buy_region(judge_node: Control) -> bool:
	return GameManager.is_in_region(bugRegionNode, judge_node)
func is_in_desk_region(judge_node: Control) -> bool:
	return GameManager.is_in_region(deskRegionNode, judge_node)
func is_in_sell_region(judge_node: Control) -> bool:
	return GameManager.is_in_region(sellRegionNode, judge_node)

var animationCheck: bool = false # 是否打开动画检查，用于防止创建卡牌时触发效果

func _ready() -> void:
	# 登记
	GameManager.shopScene = self
	handCardContainer.add_theme_constant_override("separation", separationSize)
	deskCardContainer.add_theme_constant_override("separation", separationSize)
	shopCardContainer.add_theme_constant_override("separation", separationSize)
	
	init_tripleCheckList()
	
	coinRest = GameManager.coinRest
	coinLimit = GameManager.coinLimit
	display_coin()
	display_fresh()
	display_levelUp()
	display_level()
	
	
	animationCheck = false
	init_deskCard()
	init_handCard()
	init_shopCard()
	animationCheck = true
	
	# 触发全局回合开始效果
	GameManager.playerAnimationQueue.round_start()
	await GameManager.get_tree().process_frame
	# 触发随从回合开始效果
	MinionAnimationCheck.check_round_start(deskCardList)
	
func init_deskCard() -> void:
	var deskCardInfoList: Array[CardInfo]
	for deskCardInfo in GameManager.deskCardInfoList:
		deskCardInfoList.append(deskCardInfo.duplicate())
	for info in deskCardInfoList:
		var card: Card = GameManager.create_card(info)
		cardFatherNode.add_child(card)
		card.global_position = deskPosition
		add_deskCard(card)
		add_card_tripleCheckList(card)
func init_handCard() -> void:
	var handCardInfoList: Array[CardInfo]
	for handCardInfo in GameManager.handCardInfoList:
		handCardInfoList.append(handCardInfo.duplicate())
	for info in handCardInfoList:
		var card: Card = GameManager.create_card(info)
		cardFatherNode.add_child(card)
		card.global_position = deskPosition
		add_handCard(card)
		add_card_tripleCheckList(card)
func init_shopCard() -> void:
	var shopCardInfoList: Array[CardInfo] = generate_shopCardInfoList()
	for info in shopCardInfoList:
		var card: Card = GameManager.create_card(info)
		cardFatherNode.add_child(card)
		card.global_position = shopPosition
		add_shopCard(card)
	
func create_handCard(info: CardInfo, startPosition: Vector2) -> Card:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.global_position = startPosition
	add_handCard(card)
	return card
func create_deskCard(info: CardInfo, startPosition: Vector2) -> Card:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.global_position = startPosition
	add_deskCard(card)
	return card
func create_shopCard(info: CardInfo, startPosition: Vector2) -> Card:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.global_position = startPosition
	add_shopCard(card)
	return card
	
func add_handCard(card: Card) -> void:
	card.set_belong_hand()
	handCardList.append(card)
	if animationCheck == true: # 防止刚进入商店时加载卡牌入手动画
		MinionAnimationCheck.check_add_hand(deskCardList, card)
	add_card(handCardContainer, card)
func add_deskCard(card: Card) -> void:
	card.set_belong_desk()
	deskCardList.append(card)
	add_card(deskCardContainer, card)
	sort_deskCard(card)
func add_shopCard(card: Card) -> void:
	card.set_belong_shop()
	shopCardList.append(card)
	add_card(shopCardContainer, card)

func add_card(container: HBoxContainer, card: Card) -> void:
	var followNode = Control.new()
	container.add_child(followNode)
	card.set_followNode(followNode)
	
func delete_card(card: Card) -> void:
	if card.is_belong_hand():
		delete_handCard(card)
	elif card.is_belong_desk():
		delete_deskCard(card)
	elif card.is_belong_shop():
		delete_card(card)
	
func delete_handCard(card: Card) -> void:
	remove_handCard(card)
	card.queue_free()
func delete_deskCard(card: Card) -> void:
	remove_deskCard(card)
	card.queue_free()
func delete_shopCard(card: Card) -> void:
	remove_shopCard(card)
	card.queue_free()
	
func remove_handCard(card: Card) -> void:
	handCardList.erase(card)
	remove_card(card)
func remove_deskCard(card: Card) -> void:
	deskCardList.erase(card)
	remove_card(card)
func remove_shopCard(card: Card) -> void:
	shopCardList.erase(card)
	remove_card(card)

func remove_card(card: Card) -> void:
	card.set_belong_none()
	var followNode = card.followNode
	followNode.queue_free()
	
# 私有方法
func generate_shopCardInfoList() -> Array[CardInfo]:
	var list: Array[CardInfo] = []
	for i in range(GameManager.shopCardNum):
		var cardInfo: CardInfo
		if i == GameManager.shopCardNum - 1:
			cardInfo = MagicData.get_random_magic_under_level(GameManager.shopLevel)
		else:
			cardInfo = MinionData.get_random_minion_under_level(GameManager.shopLevel)
		list.append(cardInfo)
	return list

# 判断三连
var tripleCheckList: Array[int]
var tripleTaskList: Array[Array] = []
func init_tripleCheckList() -> void:
	tripleCheckList.resize(GameManager.allMinionInfo.size())
	tripleCheckList.fill(0)
func sub_card_tripleCheckList(card: Card) -> void:
	if card.is_minion():
		var minion: Minion = card
		if minion.is_golden() == false:
			tripleCheckList[minion.get_id()] -= 1
func be_golden_sub_card_tripleCheckList(card: Card) -> void:
	tripleCheckList[card.get_id()] -= 1
func add_card_tripleCheckList(card: Card) -> void:
	if card.is_minion():
		var minion: Minion = card
		if minion.is_golden() == false:
			tripleCheckList[minion.get_id()] += 1
			if tripleCheckList[minion.get_id()] == 3:
				# 触发三连,在场上牌和手牌中寻找目标牌
				var deskAndHandCardList: Array[Card] = deskCardList + handCardList
				var targetMinionList: Array[Minion]
				for targetCard in deskAndHandCardList:
					if targetCard.is_minion():
						var targetMinion: Minion = targetCard
						if targetMinion.is_golden() == false:
							if targetMinion.get_id() == minion.get_id():
								targetMinionList.append(targetMinion)
								targetMinion.set_tripleLock(true)
								if targetMinionList.size() == 3:
									break
				# 添加到三连工作列表
				tripleTaskList.append(targetMinionList)

func _process(delta: float) -> void:
	for card in shopCardList:
		if card.is_drag():
			sort_shopCard(card)
	for card in deskCardList:
		if card.is_drag():
			sort_deskCard(card)
	# 处理三连事件
	if tripleTaskList.is_empty() == false:
		var minionList: Array[Minion] = tripleTaskList[0]
		if is_minionList_idle(minionList):
			# 先创建新的随从
			var golden_minion: Minion = GameManager.minionTemplate.instantiate()
			golden_minion.tripleGolden_info(minionList[0].get_info(), minionList[1].get_info(), minionList[2].get_info())
			# 再移除三连随从
			for minion in minionList:
				if minion.is_belong_desk():
					remove_deskCard(minion)
				else:
					remove_handCard(minion)
				minion.add_animation(MinionAnimation.BeTripleAnimation.new(minion))
			tripleTaskList.pop_front()
			tripleCheckList[minionList[0].get_id()] -= 3
			# 将合金随从挂载
			cardFatherNode.add_child(golden_minion)
			add_handCard(golden_minion)
			golden_minion.add_animation(MinionAnimation.TripleAnimation.new(golden_minion))
			
func is_minionList_idle(minionList: Array[Minion]) -> bool:
	for minion in minionList:
		if !minion.is_idle():
			return false
	return true
	
func is_list_idle(minionList: Array[Card]) -> bool:
	for minion in minionList:
		if !minion.is_idle():
			return false
	return true
	
func sort_shopCard(card: Card) -> void:
	sort(shopCardContainer, card, shopCardList)
	
func sort_deskCard(card: Card) -> void:
	sort(deskCardContainer, card, deskCardList)
	
func sort(container: HBoxContainer, card: Card, cardList: Array[Card]) -> void:
	var followNode = card.get_followNode()
	# 根据位置寻找插入点
	var leftcount = 0
	for i in range(container.get_child_count()):
		var otherNode = container.get_child(i)
		if otherNode == followNode:
			continue
		if otherNode.global_position.x < card.global_position.x:
			leftcount += 1
		else:
			break
	# 插入
	container.move_child(followNode, leftcount)
	# 排序
	cardList.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)

func _on_level_button_button_up() -> void:
	if coinRest >= GameManager.shopLevelCost[GameManager.shopLevel]:
		levelUp()

func _on_fresh_button_button_up() -> void:
	if coinRest >= 1:
		fresh()

func _on_end_button_button_up() -> void:
	end()
