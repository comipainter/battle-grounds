class_name GameUtils

const _win_score: Array[int] = [\
-30,-30,-30,-30,\
-10,-10,-10,\
15,15,15,\
80]

static func compute_score(playerInfo: PlayerInfo) -> int:
	return _win_score[playerInfo.get_curr_win_num()] + \
	playerInfo.get_blood()*2

static func get_curr_time() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d_%02d%02d%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]

static func get_random_enemy() -> PhaseData:
	var _curr_round: int = DataManager.get_game_info().get_curr_round_num()
	var _enemy_infos: Array = []
	# 遍历所有存档目录
	for _user_dir in DirAccess.get_directories_at(Path.SavePath.Base):
		var _user_path: String = Path.SavePath.Base + _user_dir + "/"
		# 跳过当前玩家的存档
		if _user_dir == DataManager.userInfo.get_id():
			continue
		# 遍历该玩家下所有存档
		for _save_dir in DirAccess.get_directories_at(_user_path):
			var _game_data_path: String = _user_path + _save_dir + "/game_data.tres"
			if not ResourceLoader.exists(_game_data_path):
				continue
			var _game_data: GameData = load(_game_data_path)
			if _game_data == null:
				continue
			# 统计fight_start阶段的计数，找到与当前回合数匹配的阶段
			var _fight_start_count: int = 1
			for _phase_data: PhaseData in _game_data.get_array():
				if _phase_data.is_fight_start():
					if _fight_start_count == _curr_round:
						_enemy_infos.append(_phase_data)
						break
					_fight_start_count += 1
	# 如果没有找到匹配的敌人，返回空FightInfo
	if _enemy_infos.is_empty():
		push_error("GameUtils.get_random_enemy: 未找到回合数 %d 的敌人存档" % _curr_round)
		return PhaseData.new()
	return _enemy_infos.pick_random()
