extends Control
class_name FightComponent

@onready var mainScene: MainScene = get_parent()

@onready var cardComponent: FightCardComponent = $Card
func get_card_component() -> FightCardComponent:
	return cardComponent

@onready var info: FightInfo = DataManager.get_fight_info()

@onready var handleComponent: FightHandleComponent = $Handle
func get_handle_component() -> FightHandleComponent:
	return handleComponent

func init() -> void:
	handleComponent.finished.connect(fight_end)
	handleComponent.init()
	cardComponent.init()
	
func set_able(_able: bool) -> void:
	handleComponent.set_able(_able)
	cardComponent.set_able(_able)
	
signal fight_started
func start() -> void:
	# 战斗开始前逻辑
	DataManager.get_game_info().set_fighting()
	
	# 初始化对战信息
	info.set_player_desk_info_collection(
		DataManager.get_last_player().get_desk_info_collection().copy()
	)
	# 将牌设置成对战设置
	for cardInfo: CardInfo in info.get_player_desk_info_collection().get_array():
		cardInfo.set_player_desk()
	info.set_player_hand_info_collection(
		DataManager.get_player_info().get_hand_info_collection()
	)
	# 将牌设置成对战设置
	for cardInfo: CardInfo in info.get_player_hand_info_collection().get_array():
		cardInfo.set_player_hand()
	
	# 初始化敌方信息
	## 从存档中选择一个作为敌方
	#var phaseData = GameUtils.get_random_enemy()
	#DataManager.enemyInfo = phaseData.get_player_info()
	#DataManager.get_fight_info().set_enemy_desk_info_collection(
		#phaseData.get_fight_info().get_player_desk_info_collection()
	#)
	#DataManager.get_fight_info().set_enemy_hand_info_collection(
		#phaseData.get_fight_info().get_player_hand_info_collection()
	#)
	# 自动生产线
	DataManager.get_enemy_info().set_desk_info_collection(CardInfoCollection.new())
	DataManager.get_enemy_info().set_hand_info_collection(CardInfoCollection.new())
	DataManager.get_enemy_info().get_desk_info_collection().add_minion_collection(
		CardUtils.create_minion_info_collection(
			DataManager.get_all_minion_data().filter_by(
				MinionDataCollection.Filter.new().set_level_range(
					1, DataManager.get_shop_info().get_level()
				)
			).pick_random_collection(
				6, false
			)
		)
	)
	info.set_enemy_desk_info_collection(DataManager.get_enemy_info().get_desk_info_collection())
	DataManager.get_enemy_info().get_hand_info_collection().add_minion_collection(
		CardUtils.create_minion_info_collection(
			DataManager.get_all_minion_data().filter_by(
				MinionDataCollection.Filter.new().set_level_range(
					1, DataManager.get_shop_info().get_level()
				)
			).pick_random_collection(
				3, false
			)
		)
	)
	info.set_enemy_hand_info_collection(DataManager.get_enemy_info().get_hand_info_collection())
	for _info in info.get_enemy_desk_info_collection().get_array():
		_info.set_stats(Stats.new(1000, 1000))

	# 记录开战时所有卡牌信息
	DataManager.save_fight_start_info()
	
	# 打开显示
	set_able(true)
	
	# 创建卡牌
	get_card_component().start()
	
	# 等待全部空闲
	while _is_all_idle() == false:
		await GameManager.mainScene.get_tree().process_frame
	
	# 触发战斗开始效果
	fight_started.emit()
	
	# 等待全部空闲
	while _is_all_idle() == false:
		await GameManager.mainScene.get_tree().process_frame
	
	# 开始战斗逻辑
	get_handle_component().start()
	
	# 禁用所有卡牌的拖拽效果
	for card: Card in CardCollection.new().add_collection(
		get_card_component().get_enemy_desk_card_collection()
	).add_collection(
		get_card_component().get_enemy_hand_card_collection()
	).add_collection(
		get_card_component().get_player_desk_card_collection()
	).add_collection(
		get_card_component().get_player_hand_card_collection()
	).get_array():
		card.get_move_component().disable_drag()

signal finished
func fight_end(winner: String) -> void:
	match winner:
		"player": 
			# 胜场数+1
			DataManager.get_player_info().set_curr_win_num(
				DataManager.get_player_info().get_curr_win_num()+1
			)
		"enemy":
			# 扣减玩家生命
			var damage: int = 0
			for card in get_card_component().get_enemy_desk_card_collection().get_array():
				damage += card.get_info().get_level()
			damage = mini(damage, 15)
			DataManager.get_player_info().take_damage(damage)
	# 计算分数
	DataManager.get_player_info().set_score(
		GameUtils.compute_score(DataManager.get_player_info())
	)
	# 记录结束时所有卡牌信息
	DataManager.save_fight_end_info(winner)
	finished.emit()

func close() -> void:
	## 记录玩家信息
	#DataManager.save_player_info()
	# 删除场上所有牌
	cardComponent.delete_all_card()

func _is_all_idle() -> bool:
	return get_card_component().get_player_desk_card_collection().is_all_idle() and \
	get_card_component().get_player_hand_card_collection().is_all_idle() and \
	get_card_component().get_enemy_desk_card_collection().is_all_idle() and \
	get_card_component().get_enemy_hand_card_collection().is_all_idle() and \
	GameManager.mainScene.get_player_component().get_animation_component().is_idle()
