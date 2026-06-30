extends Node

# 唯一Id分配
func get_uniqueId() -> String:
	return UUID.v4()

# 存档信息
var userInfo: UserInfo = UserInfo.new()

# 场标识（游戏开始时间）
var _save_id: String = ""
func set_save_id(_id: String) -> void:
	_save_id = _id
func get_save_id() -> String:
	return _save_id

# 卡牌数据库

var allMinionDataCollection: MinionDataCollection
var allMagicDataCollection: MagicDataCollection

func get_all_minion_data() -> MinionDataCollection:
	return allMinionDataCollection
func get_all_magic_data() -> MagicDataCollection:
	return allMagicDataCollection


var sellableMinionDataCollection:  MinionDataCollection
var sellableMagicDataCollection: MagicDataCollection

func get_sellable_minion_data() -> MinionDataCollection:
	return sellableMinionDataCollection
func get_sellable_magic_data() -> MagicDataCollection:
	return sellableMagicDataCollection

# 游戏数据
var gameData: GameData = GameData.new()

# 游戏信息
var gameInfo: GameInfo = GameInfo.new()
var shopInfo: ShopInfo = ShopInfo.new()
var fightInfo: FightInfo = FightInfo.new()
var playerInfo: PlayerInfo = PlayerInfo.new()
var enemyInfo: PlayerInfo = PlayerInfo.new()

func get_game_info() -> GameInfo:
	return gameInfo
func get_shop_info() -> ShopInfo:
	return shopInfo
func get_fight_info() -> FightInfo:
	return fightInfo
func get_player_info() -> PlayerInfo:
	return playerInfo
func get_enemy_info() -> PlayerInfo:
	return enemyInfo

func set_game_info(_info: GameInfo) -> void:
	gameInfo = _info
func set_shop_info(_info: ShopInfo) -> void:
	shopInfo = _info
func set_fight_info(_info: FightInfo) -> void:
	fightInfo = _info
func set_player_info(_info: PlayerInfo) -> void:
	playerInfo = _info

# 场景预加载
var minionScene = preload(Path.ScenePath.MINION)
var magicScene = preload(Path.ScenePath.MAGIC)
var mainScene = preload(Path.ScenePath.MAIN_SCENE)
var saveScene = preload(Path.ScenePath.SAVE)
var gameDataDisplayScene = preload(Path.ScenePath.GAME_DATA_DISPLAY)
var bookScene = preload(Path.ScenePath.BOOK)
var effectTabScene = preload(Path.ScenePath.EFFECT_TAB)
var effectPanelScene = preload(Path.ScenePath.EFFECT_PANEL)
var zhanhouButton = preload(Path.ScenePath.ZHANHOU_BUTTON)
var choiceButton = preload(Path.ScenePath.CHOICE_BUTTON)

func reset() -> void:
	_save_id = GameUtils.get_curr_time()
	
	gameData = GameData.new()
	
	if PathUtils.exist(Path.DataPath.MINION_TRES):
		allMinionDataCollection = load(Path.DataPath.MINION_TRES)
	else:
		allMinionDataCollection = MinionDataCollection.new()

	if PathUtils.exist(Path.DataPath.MAGIC_TRES):
		allMagicDataCollection = load(Path.DataPath.MAGIC_TRES)
	else:
		allMagicDataCollection = MagicDataCollection.new()

	sellableMinionDataCollection = allMinionDataCollection.make_sellable_collection()
	sellableMagicDataCollection = allMagicDataCollection.make_sellable_collection()
	
	
func save_shop_info() -> void:
	gameData.add_shop_phase(get_shop_info(), get_player_info())

func save_fight_start_info() -> void:
	gameData.add_fight_start_phase(get_fight_info(), get_player_info())
	
func save_fight_end_info(winner: String) -> void:
	gameData.add_fight_end_phase(get_fight_info(), get_player_info(), winner)

func get_last_player() -> PlayerInfo:
	return gameData.get_last_player()
	
func get_last_shop() -> ShopInfo:
	return gameData.get_last_shop()
	
func get_last_fight_phase() -> PhaseData:
	return gameData.get_last_fight_phase()
	
func save_game_data() -> void:
	gameData.set_save_time(GameUtils.get_curr_time())
	Utils.save_resource(gameData, get_game_data_path())
	Utils.save_resource(userInfo, get_user_info_path())

func get_game_data_path() -> String:
	return get_user_dir() + _save_id + "/" + "game_data.tres"
	
func get_user_info_path() -> String:
	return PathUtils.get_user_info_path(userInfo)
	
func get_user_dir() -> String:
	return PathUtils.get_user_info_dir(userInfo)
	
