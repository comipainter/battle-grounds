extends Control

# 场景相关
var mainMenu: MainMenu
var shopScene: ShopScene
var fightScene: FightScene
enum SCENE{MAIN_MENU, SHOP_SCENE, FIGHT_SCENE, GAME_OVER}
var sceneDict: Dictionary = {
	SCENE.MAIN_MENU: "res://scenes/main_menu.tscn",
	SCENE.SHOP_SCENE: "res://scenes/shop_scene.tscn",
	SCENE.FIGHT_SCENE: "res://scenes/fight_scene.tscn",
	SCENE.GAME_OVER: "res://scenes/game_over.tscn"
}
func change_scene(target_scene: SCENE):
	get_tree().change_scene_to_file(sceneDict.get(target_scene))

# 数据相关
var uniqueIdManager: int = 0
func get_uniqueId() -> int:
	uniqueIdManager += 1
	return uniqueIdManager
const minionInfoPath: String = "res://assets/data/minionInfo/minionInfo.csv"
const magicInfoPath: String = "res://assets/data/magicInfo/magicInfo.csv"
var allMinionInfo: Array[MinionInfo] = MinionData.load_allMinionInfo_from_csv(minionInfoPath)
var allMagicInfo: Array[MagicInfo] = MagicData.load_allMagicInfo_from_csv(magicInfoPath)
var shopMinionInfo: Array[MinionInfo] = MinionData.load_shopMinionInfo_from_csv(minionInfoPath)
var shopMagicInfo: Array[MagicInfo] = MagicData.load_shopMagicInfo_from_csv(magicInfoPath)

# 玩家相关
var startCoin: int = 100 # 开始游戏时的铸币
var startCoinLimit: int = 100 # 开始游戏时的铸币上限
var coinRest: int = 100 # 剩余铸币数
var coinLimit: int = 100 # 铸币上限
var handCardInfoList: Array[CardInfo] = []
var deskCardInfoList: Array[CardInfo] = []
var handCardLimit: int = 6 # 手牌数量限制
var deskCardLimit: int = 7 # 场上卡牌数量限制
var roundNumber: int = 1 # 回合数
var blood: int = 30 # 生命
var shield: int = 5 # 护盾
func player_take_damage(damage: int) -> void:
	if shield <= damage:
		damage -= shield
		shield = 0
	else:
		shield -= damage
		damage = 0
	blood -= damage

# 全局效果管理器
var playerEffectList: PlayerEffectList = PlayerEffectList.new([
	PlayerEffect.UseCardCount_YuanSu.new(),
	PlayerEffect.YuanSuStatsBuff.new(Stats.new(0, 0)),
])
func add_effect(effect: PlayerEffect) -> void:
	playerEffectList.add_effect(effect)

# 商店相关
var shopCardNum: int = 7 # 商店正常刷新时的卡牌数量
var shopLevelCost: Array = [0,5,5,5,5,5] # 商店升级消耗的铸币数
var shopLevel: int = 1 # 商店等级

# 卡牌相关
var minionTemplate = preload("res://scenes/minion.tscn")
var magicTemplate = preload("res://scenes/magic.tscn")
var minionInfoDisplayTemplate = preload("res://scenes/minion_info_display.tscn")
var magicInfoDisplayTemplate = preload("res://scenes/magic_info_display.tscn")
var effectPanelTemplate = preload("res://scenes/effect_panel.tscn")
enum CARDTYPE{MINION, MAGIC}
var levelSpriteTemplate = [
	null,
	preload("res://assets/image/level/1.png"),
	preload("res://assets/image/level/2.png"),
	preload("res://assets/image/level/3.png"),
	preload("res://assets/image/level/4.png"),
	preload("res://assets/image/level/5.png"),
	preload("res://assets/image/level/6.png")
]
var levelSpriteScale = [
	null,
	Vector2(0.113, 0.113),
	Vector2(0.075, 0.076),
	Vector2(0.073, 0.082),
	Vector2(0.076, 0.078),
	Vector2(0.087, 0.078),
	Vector2(0.079, 0.076)
]
var levelSingleSprite = [
	null,
	preload("res://assets/image/level/1_single.png"),
	preload("res://assets/image/level/2_single.png"),
	preload("res://assets/image/level/3_single.png"),
	preload("res://assets/image/level/4_single.png"),
	preload("res://assets/image/level/5_single.png"),
	preload("res://assets/image/level/6_single.png"),
]
var levelSingleSpriteScale = [
	null,
	Vector2(0.113, 0.113),
	Vector2(0.075, 0.076),
	Vector2(0.073, 0.082),
	Vector2(0.076, 0.078),
	Vector2(0.087, 0.078),
	Vector2(0.079, 0.076)
]

# 卡牌动画资源
var animationAssets = AnimationAssets.new()
var playerAnimationQueue = PlayerAnimationQueue.new()
func add_playerAnimation(playerAnimation: PlayerAnimation) -> void:
	playerAnimationQueue.add_animation(playerAnimation)

var tscnRegistry: Array[String]
func tscnRegistry_create(name: String) -> bool:
	if GameManager.tscnRegistry.has(name):
		return false
	GameManager.tscnRegistry.append(name)
	return true
func tscnRegistry_delete(name: String) -> void:
	GameManager.tscnRegistry.erase(name)

# 游戏音频管理器
@export var audioStreamPlayer: AudioStreamPlayer
var audioAssest: AudioAsset = AudioAsset.new()
func play_audio(stream: AudioStream) -> void:
	audioStreamPlayer.play_audio_stream(stream)
@export var gbmStreamPlayer: AudioStreamPlayer
var bgmAsset: BgmAssets = BgmAssets.new()
func play_bgm(stream: AudioStream) -> void:
	gbmStreamPlayer.play_bgm(stream)

# 音效播放器
@export var soundEffectPlayer: SoundEffectPlayer
var soundEffectAsset: SoundEffectAsset = SoundEffectAsset.new()
func play_soundEffect(stream: AudioStream) -> void:
	soundEffectPlayer.play(stream)

func stop_all_soundEffects() -> void:
	if soundEffectPlayer != null:
		soundEffectPlayer.stop_all()

func get_soundEffect_playing_count() -> int:
	if soundEffectPlayer == null:
		return 0
	return soundEffectPlayer.get_playing_count()

# 游戏阶段管理器
enum GAMESTATE{START, MENU, MENUING, SHOP, SHOPPING, FIGHT, FIGHTING, GAMEOVER}
var gameState = GAMESTATE.MENU

func _process(delta: float) -> void:
	playerAnimationQueue.play()
	match gameState:
		GAMESTATE.MENU:
			gameState = GAMESTATE.MENUING
			self.change_scene(SCENE.MAIN_MENU)
		GAMESTATE.SHOP:
			gameState = GAMESTATE.SHOPPING
			# 添加进入商店页面音频
			play_audio(audioAssest.get_shopSceneStart())
			self.change_scene(SCENE.SHOP_SCENE)
		GAMESTATE.FIGHT:
			gameState = GAMESTATE.FIGHTING
			self.change_scene(SCENE.FIGHT_SCENE)

# 逻辑方法
func end_menu() -> void:
	if gameState == GAMESTATE.MENUING:
		# 先重置金币，再进入商店页面
		coinRest = coinLimit
		gameState = GAMESTATE.SHOP

func end_shop() -> void:
	if gameState == GAMESTATE.SHOPPING:
		gameState = GAMESTATE.FIGHT
		
func end_fight() -> void:
	if gameState == GAMESTATE.FIGHTING:
		if blood <= 0:
			game_over()
			return
		coinRest = coinLimit
		roundNumber += 1
		gameState = GAMESTATE.SHOP
func game_over() -> void:
	gameState = GAMESTATE.GAMEOVER
	self.change_scene(SCENE.GAME_OVER)
	
# 配置方法
func is_menuing() -> bool:
	return gameState == GAMESTATE.MENUING
	
func is_shopping() -> bool:
	return gameState == GAMESTATE.SHOPPING
	
func is_fighting() -> bool:
	return gameState == GAMESTATE.FIGHTING
	
# 静态方法
func is_in_region(regionNode: Control, judgeNode: Control) -> bool:
	var regionMinPosition = regionNode.global_position
	var regionMaxPosition = regionNode.global_position + regionNode.size
	var judgeMinPosition = judgeNode.global_position
	var judgeMaxPosition = judgeNode.global_position + judgeNode.size
	if regionMinPosition.x < judgeMinPosition.x:
		if regionMinPosition.y < judgeMinPosition.y:
			if regionMaxPosition.x > judgeMaxPosition.x:
				if regionMaxPosition.y > judgeMaxPosition.y:
					return true
	return false
	
func is_point_in_region(regionNode: Control, judgePos: Vector2) -> bool:
	var regionMinPosition = regionNode.global_position
	var regionMaxPosition = regionNode.global_position + regionNode.size
	if regionMinPosition.x < judgePos.x:
		if regionMinPosition.y < judgePos.y:
			if regionMaxPosition.x > judgePos.x:
				if regionMaxPosition.y > judgePos.y:
					return true
	return false
	
func create_card(info: CardInfo) -> Card:
	if info.type == "minion":
		var minion: Minion = self.minionTemplate.instantiate()
		minion.set_info(info)
		if minion.is_ronghe():
			for baseMinionInfo in minion.get_minionInfo().get_baseMinionInfoList():
				minion.add_initBaseMinion(create_card(baseMinionInfo))
		return minion
	elif info.type == "magic":
		var magic: Magic = self.magicTemplate.instantiate()
		magic.set_info(info)
		return magic
	else:
		return null

func find_card(findId: int) -> MinionInfo:
	var findList: Array[CardInfo] = GameManager.deskCardInfoList + GameManager.handCardInfoList
	for findCardInfo: CardInfo in findList:
		if findCardInfo.type == "minion":
			var findMinionInfo: MinionInfo = findCardInfo
			if findMinionInfo.uniqueId == findId:
				return findMinionInfo
			if findMinionInfo.is_ronghe():
				for baseMinionInfo in findMinionInfo.get_baseMinionInfoList():
					if baseMinionInfo.uniqueId == findId:
						return baseMinionInfo
	return null
