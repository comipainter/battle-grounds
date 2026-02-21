extends Node2D

class_name FightScene

@export var enemyHandCardContainer: HBoxContainer
@export var enemyDeskCardContainer: HBoxContainer
@export var playerHandCardContainer: HBoxContainer
@export var playerDeskCardContainer: HBoxContainer
@export var cardFatherNode: Control

@export var playerDeskPosition: Vector2
@export var playerHandPosition: Vector2
@export var enemyDeskPosition: Vector2
@export var enemyHandPosition: Vector2

# 分离参数
var separationSize: int = 250

var playerHandCardList: Array[Card] = []
var playerDeskCardList: Array[Card] = []
var enemyHandCardList: Array[Card] = []
var enemyDeskCardList: Array[Card] = []
var initEnemyDeskCardNum: int = 5

var animationCheck: bool = false

func _ready() -> void:
	GameManager.fightScene = self
	
	playerHandCardContainer.add_theme_constant_override("separation", separationSize)
	playerDeskCardContainer.add_theme_constant_override("separation", separationSize)
	enemyHandCardContainer.add_theme_constant_override("separation", separationSize)
	enemyDeskCardContainer.add_theme_constant_override("separation", separationSize)
	
	var playerDeskCardInfoList: Array[CardInfo]
	for deskCardInfo in GameManager.deskCardInfoList:
		playerDeskCardInfoList.append(deskCardInfo.duplicate())
	var playerHandCardInfoList: Array[CardInfo]
	for handCardInfo in GameManager.handCardInfoList:
		playerHandCardInfoList.append(handCardInfo.duplicate())
	var enemyDeskCardInfoList: Array[CardInfo] = generate_enemyCardInfoList()
	
	for info in playerHandCardInfoList:
		create_player_handCard(info, playerHandPosition)
	for info in playerDeskCardInfoList:
		create_player_deskCard(info, playerDeskPosition)
	for info in enemyDeskCardInfoList:
		create_enemy_deskCard(info, enemyDeskPosition)
	
	animationCheck = true
		
func end() -> void:
	var handInfoList: Array[CardInfo] = []
	for card in playerHandCardList:
		handInfoList.append(card.get_info())
	GameManager.handCardInfoList = handInfoList.duplicate(true)
	GameManager.end_fight()
	
enum FIGHTSTATE{PREPARE, ATTACK, ATTACKING, END}
var fightState = FIGHTSTATE.PREPARE
# 决定哪方先攻击
var player_enemy_list = ["player", "enemy"]
var curr = player_enemy_list[randi()%2]

func _process(delta: float) -> void:
	match fightState:
		FIGHTSTATE.PREPARE:
			if is_all_idle():
				fightState = FIGHTSTATE.ATTACK
				for minion: Minion in playerDeskCardList:
					minion.attackPrior = 0
				for minion: Minion in enemyDeskCardList:
					minion.attackPrior = 0
		FIGHTSTATE.ATTACK:
			# 先检查是否有一方随从全部退场
			if is_all_dead():
				print("对战结束, 平局")
			elif is_player_dead():
				fightState = FIGHTSTATE.END
				print("对战结束, 敌方胜利")
				end()
			elif is_enemy_dead():
				fightState = FIGHTSTATE.END
				print("对战结束, 玩家胜利")
				end()
			else:
				fightState = FIGHTSTATE.ATTACKING
				match curr:
					"player":
						# 当前玩家方随从先攻击
						var behitMinion: Minion = get_behit_minion(enemyDeskCardList)
						var attackMinion: Minion = get_attack_minion(playerDeskCardList)
						attack(attackMinion, behitMinion)
						curr = "enemy"
					"enemy":
						# 当前敌方随从先攻击
						var behitMinion: Minion = get_behit_minion(playerDeskCardList)
						var attackMinion: Minion = get_attack_minion(enemyDeskCardList)
						attack(attackMinion, behitMinion)
						curr = "player"
		FIGHTSTATE.ATTACKING:
			# 全部攻击动画完毕，则允许下次攻击
			if is_all_idle():
				fightState = FIGHTSTATE.ATTACK
				
func delete_card(card: Card) -> void:
	if card.is_belong_player():
		delete_player_deskCard(card)
	else:
		delete_enemy_deskCard(card)
				
func attack(attackMinion: Minion, behitMinion: Minion) -> void:
	attackMinion.attackPrior += 1
	attackMinion.add_animation(MinionAnimation.AttackAnimation.new(attackMinion, behitMinion))
	
func get_behit_minion(cardList: Array[Card]) -> Card:
	return cardList[randi() % cardList.size()]

func get_attack_minion(cardList: Array[Card]) -> Card:
	var leftMinion: Minion = cardList[0]
	var minPosition: Vector2 = Vector2(10000, 0)
	var minPrior: int = 10000
	# 先找最小优先级
	for minion: Minion in cardList:
		minPrior = min(minion.attackPrior, minPrior)
	for minion: Minion in cardList:
		if (minion.global_position.x < minPosition.x) and \
		(minion.attackPrior == minPrior):
			minPosition = minion.global_position
			leftMinion = minion
	return leftMinion

func is_all_idle() -> bool:
	return (is_list_idle(playerDeskCardList) and \
	is_list_idle(playerHandCardList) and \
	is_list_idle(enemyDeskCardList) and \
	is_list_idle(enemyHandCardList) and \
	boxNum_equals_cardNum())

func boxNum_equals_cardNum() -> bool:
	return playerDeskCardList.size() == playerDeskCardContainer.get_child_count() and \
	playerHandCardList.size() == playerHandCardContainer.get_child_count() and \
	enemyDeskCardList.size() == enemyDeskCardContainer.get_child_count() and \
	enemyHandCardList.size() == enemyHandCardContainer.get_child_count()
	
func is_list_idle(cardList: Array[Card]) -> bool:
	for card in cardList:
		if !card.is_idle():
			return false
	return true
	
func is_all_dead() -> bool:
	return is_player_dead() and is_enemy_dead()
	
func is_player_dead() -> bool:
	for minion: Minion in playerDeskCardList:
		if !minion.is_dead():
			return false
	return true
	
func is_enemy_dead() -> bool:
	for minion: Minion in enemyDeskCardList:
		if !minion.is_dead():
			return false
	return true
	
func generate_enemyCardInfoList() -> Array[CardInfo]:
	var list: Array[CardInfo] = []
	for i in range(initEnemyDeskCardNum):
		var info: CardInfo = MinionData.get_random_minion()
		list.append(info)
	return list
	
func create_player_handCard(info: CardInfo, startPosition: Vector2) -> void:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_player_hand()
	card.global_position = startPosition
	playerHandCardList.append(card)
	if animationCheck == true: # 防止刚进入场景时加载卡牌计算动画
		MinionAnimationCheck.check_add_hand(playerDeskCardList, card)
	add_card(playerHandCardContainer, card)
func create_player_deskCard(info: CardInfo, startPosition: Vector2) -> void:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_player_desk()
	card.global_position = startPosition
	playerDeskCardList.append(card)
	add_card(playerDeskCardContainer, card)
func create_enemy_handCard(info: CardInfo, startPosition: Vector2) -> void:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_enemy_hand()
	card.global_position = startPosition
	enemyHandCardList.append(card)
	add_card(enemyHandCardContainer, card)
func create_enemy_deskCard(info: CardInfo, startPosition: Vector2) -> void:
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_enemy_desk()
	card.global_position = startPosition
	enemyDeskCardList.append(card)
	add_card(enemyDeskCardContainer, card)

func add_card(container: HBoxContainer, card: Card) -> void:
	card.drag(false)
	var followNode = Control.new()
	container.add_child(followNode)
	card.set_followNode(followNode)
	
func delete_player_deskCard(card: Card) -> void:
	playerDeskCardList.erase(card)
	remove_card(card)

func delete_enemy_deskCard(card: Card) -> void:
	enemyDeskCardList.erase(card)
	remove_card(card)

func remove_card(card: Card) -> void:
	var followNode = card.followNode
	followNode.queue_free()
	card.queue_free()
