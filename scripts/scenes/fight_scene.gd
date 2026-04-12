extends Node2D

class_name FightScene

# 节点相关
@export var enemyHandCardContainer: HBoxContainer
@export var enemyDeskCardContainer: HBoxContainer
@export var playerHandCardContainer: HBoxContainer
@export var playerDeskCardContainer: HBoxContainer
@export var cardFatherNode: Control

@export var playerDeskPosition: Vector2
@export var playerHandPosition: Vector2
@export var enemyDeskPosition: Vector2
@export var enemyHandPosition: Vector2

@export var bloodLabel: Label
@export var shieldLabel: Label
func display_boold_and_shield() -> void:
	bloodLabel.text = str(GameManager.blood)
	shieldLabel.text = str(GameManager.shield)

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
	
	display_boold_and_shield()
	
	# 播放战斗开始音频
	GameManager.play_audio(GameManager.audioAssest.get_fightSceneStart())
	
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
		
func end(winner: String) -> void:
	var handInfoList: Array[CardInfo] = []
	for card in playerHandCardList:
		handInfoList.append(card.get_info())
	GameManager.handCardInfoList = handInfoList.duplicate(true)
	# 播放结算动画
	var playerPosition: Vector2 = Vector2(-32, 512)
	var enemyPosition: Vector2 = Vector2(-8, -472)
	var fightEndAnimation: PlayerAnimation.FightEnd
	if winner == "player":
		fightEndAnimation = PlayerAnimation.FightEnd.new(playerDeskCardList, playerPosition, enemyPosition)
		GameManager.add_playerAnimation(fightEndAnimation)
		await fightEndAnimation.finished
	elif winner == "enemy":
		fightEndAnimation = PlayerAnimation.FightEnd.new(enemyDeskCardList, enemyPosition, playerPosition)
		GameManager.add_playerAnimation(fightEndAnimation)
		await fightEndAnimation.finished
		var damage: int = 0
		for card in enemyDeskCardList:
			damage += card.get_level()
		GameManager.player_take_damage(damage)
	GameManager.end_fight()
	
enum FIGHTSTATE{PREPARE, ATTACK, ATTACKING, DIE, DYING, END}
var fightState = FIGHTSTATE.PREPARE
# 决定哪方先攻击
var player_enemy_list = ["player", "enemy"]
var curr = player_enemy_list[randi()%2]
var fengnuMinion: Minion
var fengnuAttack: bool = false # 当前是否触发了风怒的额外攻击

@warning_ignore("unused_parameter")
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
				fightState = FIGHTSTATE.END
				# 播放战斗平局声音
				GameManager.play_audio(GameManager.audioAssest.get_fightDraw())
				print("对战结束, 平局")
				end("draw")
			elif is_player_dead():
				fightState = FIGHTSTATE.END
				# 播放战斗失败声音
				GameManager.play_audio(GameManager.audioAssest.get_fightDefeat())
				print("对战结束, 敌方胜利")
				end("enemy")
			elif is_enemy_dead():
				fightState = FIGHTSTATE.END
				# 播放战斗胜利声音
				GameManager.play_audio(GameManager.audioAssest.get_fightVictory())
				print("对战结束, 玩家胜利")
				end("player")
			else:
				fightState = FIGHTSTATE.ATTACKING
				if fengnuAttack and is_instance_valid(fengnuMinion): # 如果当前是风怒随从的额外攻击回合并且该随从还活着
					var attackMinion: Minion = fengnuMinion
					var behitMinion: Minion
					if fengnuMinion.is_belong_player():
						behitMinion = get_behit_minion(enemyDeskCardList)
					else:
						behitMinion = get_behit_minion(playerDeskCardList)
					attack(attackMinion, behitMinion)
					return
				match curr:
					"player":
						# 当前玩家方随从先攻击
						var behitMinion: Minion = get_behit_minion(enemyDeskCardList)
						var attackMinion: Minion = get_attack_minion(playerDeskCardList)
						# 如果是风怒随从，则标记下次攻击属于风怒随从的额外攻击
						if attackMinion.is_fengnu():
							fengnuAttack = true
							fengnuMinion = attackMinion
						curr = "enemy"
						attack(attackMinion, behitMinion)
					"enemy":
						# 当前敌方随从先攻击
						var behitMinion: Minion = get_behit_minion(playerDeskCardList)
						var attackMinion: Minion = get_attack_minion(enemyDeskCardList)
						# 如果是风怒随从，则标记下次攻击属于风怒随从的额外攻击
						if attackMinion.is_fengnu():
							fengnuAttack = true
							fengnuMinion = attackMinion
						curr = "player"
						attack(attackMinion, behitMinion)
		FIGHTSTATE.ATTACKING:
			await GameManager.get_tree().process_frame
			# 全部攻击动画完毕，则进行死亡判定
			if is_all_idle():
				fightState = FIGHTSTATE.DIE
		FIGHTSTATE.DIE:
			fightState = FIGHTSTATE.DYING
			# 检查死亡的随从
			for minion: Minion in playerDeskCardList:
				if minion.is_dead():
					# 播放死亡音效
					GameManager.play_audio(GameManager.audioAssest.minion_die(minion.get_info()))
					minion.add_animation(MinionAnimation.DieAnimation.new(minion))
			for minion: Minion in enemyDeskCardList:
				if minion.is_dead():
					# 播放死亡音效
					GameManager.play_audio(GameManager.audioAssest.minion_die(minion.get_info()))
					minion.add_animation(MinionAnimation.DieAnimation.new(minion))
		FIGHTSTATE.DYING:
			await GameManager.get_tree().process_frame
			# 全部死亡动画完毕，则进入下次攻击
			if is_all_idle():
				fightState = FIGHTSTATE.ATTACK
				
func attack(attackMinion: Minion, behitMinion: Minion) -> void:
	attackMinion.attackPrior = true
	# 播放攻击声音
	GameManager.play_audio(GameManager.audioAssest.minion_attack(attackMinion.get_info()))
	attackMinion.add_animation(MinionAnimation.AttackStartAnimation.new(attackMinion, behitMinion))
	
func get_behit_minion(cardList: Array[Card]) -> Card:
	# 筛选嘲讽随从
	var chaofengList: Array[Minion] = []
	for card in cardList:
		if card.is_minion():
			var minion: Minion = card
			if minion.is_chaofeng():
				chaofengList.append(minion)
	if chaofengList.is_empty():
		return cardList[randi() % cardList.size()]
	else:
		return chaofengList[randi() % chaofengList.size()]

func get_attack_minion(cardList: Array[Card]) -> Card:
	var leftMinion: Minion = cardList[0]
	var minPosition: Vector2 = Vector2(10000, 0)
	# 找没有攻击过的随从中的最左边的随从
	for minion: Minion in cardList:
		if (minion.global_position.x < minPosition.x) and (minion.attackPrior == false):
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

	# 获取当前回合数
	var roundNum: int = GameManager.roundNumber

	# 根据回合数计算敌人数量（基础3个，每2回合+1，上限7个）
	@warning_ignore("integer_division")
	var enemyCount: int = mini(3 + (roundNum - 1) / 2, GameManager.deskCardLimit)

	# 根据回合数计算敌人等级上限（回合1-2: 2级, 回合3-4: 3级, 回合5-6: 4级, 回合7-8: 5级, 回合9+: 6级）
	@warning_ignore("integer_division")
	var enemyLevelCap: int = mini(1 + (roundNum + 1) / 2, GameManager.shopLevelCost.size())

	# 根据回合数计算基础属性加成（回合1: +0, 每回合+1攻击和+1生命）
	var baseStatBonus: int = roundNum - 1

	# 根据回合数计算属性乘数（回合1: 1.0, 每回合+0.1，上限2.0）
	@warning_ignore("narrowing_conversion")
	var statMultiplier: float = mini(1.0 + (roundNum - 1) * 0.1, 2.0)

	# 生成敌人随从
	for i in range(enemyCount):
		# 随机选择等级范围内的随从
		var info: MinionInfo = MinionData.get_random_minion_under_level(GameManager.shopMinionInfo, enemyLevelCap)

		# 应用属性乘数
		var newAttack: int = int(info.attack * statMultiplier)
		var newHealth: int = int(info.health * statMultiplier)

		# 应用基础属性加成
		newAttack += baseStatBonus
		newHealth += baseStatBonus

		info.set_stats(Stats.new(newAttack, newHealth))
		list.append(info)

	return list
	
func create_player_handCard(info: CardInfo, startPosition: Vector2) -> Card:
	if GameManager.handCardLimit == playerHandCardList.size():
		return null
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_player_hand()
	card.global_position = startPosition
	playerHandCardList.append(card)
	if animationCheck == true: # 防止刚进入场景时加载卡牌计算动画
		MinionAnimationCheck.check_add_hand(playerDeskCardList, card)
	add_card(playerHandCardContainer, card)
	return card
func create_player_deskCard(info: CardInfo, startPosition: Vector2) -> Card:
	if GameManager.deskCardLimit == playerDeskCardList.size():
		return null
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_player_desk()
	card.global_position = startPosition
	playerDeskCardList.append(card)
	add_card(playerDeskCardContainer, card)
	sort(playerDeskCardContainer, card, playerDeskCardList)
	return card
func create_enemy_handCard(info: CardInfo, startPosition: Vector2) -> Card:
	if GameManager.handCardLimit == enemyHandCardList.size():
		return null
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_enemy_hand()
	card.global_position = startPosition
	enemyHandCardList.append(card)
	add_card(enemyHandCardContainer, card)
	return card
func create_enemy_deskCard(info: CardInfo, startPosition: Vector2) -> Card:
	if GameManager.deskCardLimit == enemyDeskCardList.size():
		return null
	var card: Card = GameManager.create_card(info)
	cardFatherNode.add_child(card)
	card.set_belong_enemy_desk()
	card.global_position = startPosition
	enemyDeskCardList.append(card)
	add_card(enemyDeskCardContainer, card)
	sort(enemyDeskCardContainer, card, enemyDeskCardList)
	return card

func add_card(container: HBoxContainer, card: Card) -> void:
	card.drag(false)
	var followNode = Control.new()
	container.add_child(followNode)
	card.set_followNode(followNode)

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

func delete_card(card: Card) -> void:
	if is_instance_valid(card):
		if card.is_belong_player():
			delete_player_deskCard(card)
		else:
			delete_enemy_deskCard(card)

func delete_player_deskCard(card: Card) -> void:
	remove_card(card)
	card.queue_free()
	
func delete_enemy_deskCard(card: Card) -> void:
	remove_card(card)
	card.queue_free()

func remove_card(card: Card) -> void:
	if card.is_belong_enemy():
		enemyDeskCardList.erase(card)
	if card.is_belong_player():
		playerDeskCardList.erase(card)
	card.set_belong_none()
	var followNode = card.followNode
	if is_instance_valid(followNode):
		followNode.queue_free()
	
