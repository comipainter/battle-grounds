extends Resource
class_name GameData

@export var phaseDataArray: Array[PhaseData] = []

@export var startTime: String = GameUtils.get_curr_time()

@export var saveTime: String = GameUtils.get_curr_time()
func set_save_time(_time: String) -> void:
	saveTime = _time

func get_array() -> Array[PhaseData]:
	return phaseDataArray

func add_shop_phase(_shopInfo: ShopInfo, _playerInfo: PlayerInfo) -> void:
	phaseDataArray.append(
		PhaseData.new().set_shop().set_shop_info(
			_shopInfo.copy()
		).set_player_info(
			_playerInfo.copy()
		)
	)

func add_fight_start_phase(_fightInfo: FightInfo, _playerInfo: PlayerInfo) -> void:
	phaseDataArray.append(
		PhaseData.new().set_fight_start().set_fight_info(
			_fightInfo.copy()
		).set_player_info(
			_playerInfo.copy()
		)
	)
	
func add_fight_end_phase(_fightInfo: FightInfo, _playerInfo: PlayerInfo, _winner: String) -> void:
	phaseDataArray.append(
		PhaseData.new().set_fight_end().set_fight_info(
			_fightInfo.copy()
		).set_player_info(
			_playerInfo.copy()
		).set_winner(_winner)
	)

func get_last_player() -> PlayerInfo:
	var arr = get_array()
	if arr.size() == 0:
		push_warning("no phase saved")
		return PlayerInfo.new()
	# 从后往前遍历
	for i in range(arr.size() - 1, -1, -1):
		var phaseData: PhaseData = arr[i]
		if phaseData.is_shop():
			return phaseData.get_player_info()
	push_error("no legal player phase")
	return PlayerInfo.new()

func get_last_shop() -> ShopInfo:
	var arr = get_array()
	if arr.size() == 0:
		push_warning("no phase saved")
		return ShopInfo.new()
	# 从后往前遍历
	for i in range(arr.size() - 1, -1, -1):
		var phaseData: PhaseData = arr[i]
		if phaseData.is_shop():
			return phaseData.get_shop_info()
	push_error("no legal shop phase")
	return ShopInfo.new()

func get_last_fight_phase() -> PhaseData:
	var arr = get_array()
	if arr.size() == 0:
		push_warning("no phase saved")
		return null
	# 从后往前遍历
	for i in range(arr.size() - 1, -1, -1):
		var phaseData: PhaseData = arr[i]
		if phaseData.is_fight_end():
			return phaseData
	push_error("no legal fight end phase")
	return null
