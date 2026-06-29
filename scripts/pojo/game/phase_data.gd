extends Resource
class_name PhaseData

@export var phaseType: PhaseType = PhaseType.new()

func is_shop() -> bool:
	return phaseType.is_shop()
func set_shop() -> PhaseData:
	phaseType.set_shop()
	return self
	
func is_fight_start() -> bool:
	return phaseType.is_fight_start()
func set_fight_start() -> PhaseData:
	phaseType.set_fight_start()
	return self
	
func is_fight_end() -> bool:
	return phaseType.is_fight_end()
func set_fight_end() -> PhaseData:
	phaseType.set_fight_end()
	return self

@export var playerInfo: PlayerInfo = PlayerInfo.new()
func get_player_info() -> PlayerInfo:
	return playerInfo
func set_player_info(_info: PlayerInfo) -> PhaseData:
	playerInfo = _info
	return self

@export var shopInfo: ShopInfo = ShopInfo.new()
func get_shop_info() -> ShopInfo:
	return shopInfo
func set_shop_info(_info: ShopInfo) -> PhaseData:
	shopInfo = _info
	return self
	
@export var fightInfo: FightInfo = FightInfo.new()
func get_fight_info() -> FightInfo:
	return fightInfo
func set_fight_info(_info: FightInfo) -> PhaseData:
	fightInfo = _info
	return self

@export var winner: String = ""
func set_winner(_winner: String) -> PhaseData:
	winner = _winner
	return self
func get_winner() -> String:
	return winner
