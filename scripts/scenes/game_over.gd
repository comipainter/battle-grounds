extends Control

class_name GameOver

@onready var roundLabel: Label = $Panel/RoundLabel
@onready var restartButton: Button = $Panel/RestartButton
@onready var mainMenuButton: Button = $Panel/MainMenuButton

func _ready() -> void:
	# 显示玩家坚持的回合数
	roundLabel.text = "你坚持了 " + str(GameManager.roundNumber) + " 回合"

func _on_restart_button_button_up() -> void:
	# 重置游戏数据
	_reset_game()
	# 返回商店场景
	GameManager.gameState = GameManager.GAMESTATE.SHOP

func _on_main_menu_button_button_up() -> void:
	# 重置游戏数据
	_reset_game()
	# 返回主菜单
	GameManager.gameState = GameManager.GAMESTATE.MENU

func _reset_game() -> void:
	# 重置玩家数据
	GameManager.blood = 30
	GameManager.shield = 5
	GameManager.coinRest = GameManager.startCoin
	GameManager.coinLimit = GameManager.startCoinLimit
	GameManager.roundNumber = 1
	GameManager.shopLevel = 1
	GameManager.handCardInfoList.clear()
	GameManager.deskCardInfoList.clear()
	GameManager.uniqueIdManager = 0
	# 重置效果列表
	GameManager.playerEffectList = PlayerEffectList.new([
		PlayerEffect.UseCardCount_YuanSu.new(),
		PlayerEffect.YuanSuStatsBuff.new(Stats.new(0, 0)),
	])
