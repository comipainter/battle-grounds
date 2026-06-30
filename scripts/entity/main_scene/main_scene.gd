extends Control
class_name MainScene

# 卡牌数据

@onready var shopCompoent: ShopComponent = $Shop
@onready var fightComponent: FightComponent = $Fight
@onready var playerComponent: PlayerComponent = $Player

@onready var gameInfo: GameInfo = DataManager.get_game_info()
@onready var playerInfo: PlayerInfo = DataManager.get_player_info()
	
func get_shop_component() -> ShopComponent:
	return shopCompoent
	
func get_fight_component() -> FightComponent:
	return fightComponent
	
func get_player_component() -> PlayerComponent:
	return playerComponent

func _ready() -> void:
	# 注册场景
	GameManager.set_main_scene(self)
	shopCompoent.finished.connect(
		func():
			if not is_game_over:
				await shopCompoent.close()
				gameInfo.set_fighting()
				fightComponent.start()
			else:
				await shopCompoent.close()
				DataManager.save_game_data()
				game_overed.emit()
	)
	fightComponent.finished.connect(
		func():
			if not is_game_over:
				fightComponent.close()
				gameInfo.set_shoping()
				shopCompoent.start()
			else:
				fightComponent.close()
				DataManager.save_game_data()
				game_overed.emit()
	)
	playerInfo.dead.connect(
		func():
			is_game_over = true
	)
	playerInfo.win_num_changed.connect(
		func():
			if playerInfo.get_curr_win_num() >= 10:
				is_game_over = true
	)
	# 启动初始化
	shopCompoent.init()
	fightComponent.init()
	playerComponent.init()
	
	playerComponent.start()
	
	shopCompoent.set_able(false)
	fightComponent.set_able(false)
	
	gameInfo.set_shoping()
	shopCompoent.start()
	#fightComponent.start()

var is_game_over: bool = false
signal game_overed
