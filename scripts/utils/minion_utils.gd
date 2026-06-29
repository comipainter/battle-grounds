class_name MinionUtils

static func get_race_name(race: Race.Type) -> String:
	if race == Race.Type.None:
		return ""

	var names: Array[String] = []
	if race & Race.Type.HaiDao:
		names.append(RaceName.NAMES[0])
	if race & Race.Type.YuanSu_Wind:
		names.append(RaceName.NAMES[1])
	if race & Race.Type.YuanSu_Shui:
		names.append(RaceName.NAMES[2])
	if race & Race.Type.YuanSu_Tu:
		names.append(RaceName.NAMES[3])
	if race & Race.Type.YuanSu_Huo:
		names.append(RaceName.NAMES[4])
	#if race & Race.Type.YuanSu:
		#names.append(RaceName.NAMES[5])
	if race & Race.Type.NaJia:
		names.append(RaceName.NAMES[6])

	return ", ".join(names)

static func is_race(race: Race.Type, expected_race: Race.Type) -> bool:
	if expected_race == Race.Type.None:
		return race == Race.Type.None
	return (race & expected_race) != 0
	
static func add_stats(from: Minion, to: Minion, stats: Stats, forever: bool = false) -> void:
	var buff_stats: Stats = Stats.new(0, 0)
	if MinionUtils.is_race(from.get_info().get_race(), Race.Type.YuanSu):
		buff_stats = (CardUtils.get_belong_player_effect(from).find_effect(
			Effect_YuanSuStatsBuff
		)as Effect_YuanSuStatsBuff).get_stats()
	stats.add_stats(buff_stats)
	to.get_info().add_stats(stats)
	if forever == true:
		if to.get_info().is_shopping() == false and to.get_info().is_player():
			var info: MinionInfo = MinionInfoCollection.new().add_collection(
				DataManager.get_shop_info().get_desk_info_collection().get_minion_collection()
			).add_collection(
				DataManager.get_shop_info().get_hand_info_collection().get_minion_collection()
			).filter_by(
				MinionInfoCollection.Filter.new().set_uniqueId(to.get_info().get_uniqueId())
			).get_array().front()
			if info != null:
				info.add_stats(stats)
				
static func add_stats_from_magic(from: Magic, to: Minion, stats: Stats) -> void:
	var buff_stats: Stats = Stats.new(0, 0)
	if from.get_info().is_suzao():
		buff_stats = (CardUtils.get_belong_player_effect(from).find_effect(
			Effect_SuZaoStatsBuff
		)as Effect_SuZaoStatsBuff).get_stats()
	stats.add_stats(buff_stats)
	to.get_info().add_stats(stats)
	
static func add_stats_uncare_from(to: Minion, stats: Stats) -> void:
	to.get_info().add_stats(stats)
				
static func triple(info1: MinionInfo, info2: MinionInfo, info3: MinionInfo) -> MinionInfo:
	var new_info: MinionInfo = CardUtils.create_minion_info(
		DataManager.get_all_minion_data().filter_by(
			MinionDataCollection.Filter.new().set_id(info1.get_id())
		).get_array().get(0)
	)
	
	# 计算三连后的属性值
	var golden_stats: Stats = Stats.new(0, 0)
	golden_stats.add_stats(info1.get_stats())
	golden_stats.add_stats(info2.get_stats())
	golden_stats.add_stats(info3.get_stats())
	golden_stats.sub_stats(info1.get_origin_stats())
	new_info.set_stats(golden_stats)
	new_info.set_origin_stats(StatsUtils.mul_stats(info1.get_stats(), 2))
	
	# 合并关键词
	new_info.get_keyword_info().set_chaofeng(
		info1.get_keyword_info().is_chaofeng() or info2.get_keyword_info().is_chaofeng() or info3.get_keyword_info().is_chaofeng()
	)
	new_info.get_keyword_info().set_shengdun(
		info1.get_keyword_info().is_shengdun() or info2.get_keyword_info().is_shengdun() or info3.get_keyword_info().is_shengdun()
	)
	new_info.get_keyword_info().set_fengnu(
		info1.get_keyword_info().is_fengnu() or info2.get_keyword_info().is_fengnu() or info3.get_keyword_info().is_fengnu()
	)
	
	# 处理计数器
	new_info.get_counter_info().set_able(
		info1.get_counter_info().is_able() and info2.get_counter_info().is_able() and info3.get_counter_info().is_able()
	)
	new_info.get_counter_info().set_count(
		mini(
			mini(info1.get_counter_info().get_count(), info2.get_counter_info().get_count()),
			info3.get_counter_info().get_count()
		)
	)
	new_info.get_counter_info().set_limit(
		mini(
			mini(info1.get_counter_info().get_limit(), info2.get_counter_info().get_limit()),
			info3.get_counter_info().get_limit()
		)
	)
	new_info.get_counter_info().set_match_name(
		info1.get_counter_info().get_match_name()
	)
	
	# 处理提升计数器
	new_info.get_boost_counter_info().set_able(
		info1.get_boost_counter_info().is_able() and info2.get_boost_counter_info().is_able() and info3.get_boost_counter_info().is_able()
	)
	new_info.get_boost_counter_info().set_count(
		maxi(
			maxi(info1.get_boost_counter_info().get_count(), info2.get_boost_counter_info().get_count()),
			info3.get_boost_counter_info().get_count()
		)
	)
	
	# 处理效果集合
	new_info.get_effect_collection().array =\
		info1.get_effect_collection().get_array() + \
		info2.get_effect_collection().get_array() + \
		info3.get_effect_collection().get_array()
	
	new_info.set_golden()
	
	return new_info

static func ronghe_info(info1: MinionInfo, info2: MinionInfo) -> MinionInfo:
	var new_info: MinionInfo = MinionInfo.new()
	
	# 创建新名字
	var new_name_array: Array = (info1.name + info2.name).split("")
	new_name_array.shuffle()
	var new_name: String = "".join(new_name_array)
	new_name = new_name.substr(0, int(new_name.length()/2))
	new_info.name = new_name
	
	# 设置id为0表示该随从不可匹配或者查找（不能为-1，这是filter的设置）
	new_info.id = 0
	
	new_info.level = int((info1.get_level() + info2.get_level())/2)
	new_info.sellable = false
	new_info.description = "力量的形态千变万化"
	new_info.type.set_minion()
	new_info.uniqueId = DataManager.get_uniqueId()
	
	# 开始设置随从特有部分
	new_info.golden = false
	new_info.set_race([info1.race, info2.race].pick_random())
	
	# 标记为融合
	new_info.set_ronghe()
	
	if info1.is_ronghe():
		for base_info in info1.get_base_info_array():
			new_info.add_base_info(base_info)
	else:
		new_info.add_base_info(info1)
	if info2.is_ronghe():
		for base_info in info2.get_base_info_array():
			new_info.add_base_info(base_info)
	else:
		new_info.add_base_info(info2)
	
	new_info.set_ronghe_info(MinionInfo.new())
	new_info.get_ronghe_info().set_stats(Stats.new(0, 0))
	new_info.set_stats(MinionUtils.compute_total_stats(new_info))
	MinionUtils.compute_total_shengdun(new_info)
	MinionUtils.compute_total_chaofeng(new_info)
	MinionUtils.compute_total_fengnu(new_info)
	return new_info

static func ronghe(minion1: Minion, minion2: Minion) -> void:
	CardUtils.remove_card(minion1)
	CardUtils.remove_card(minion2)
	CardUtils.create_hand_card(
		MinionUtils.ronghe_info(minion1.get_info().copy(), minion2.get_info().copy()),
		(minion1.global_position + minion2.global_position)/2,
		minion1,
		func(_card: Card):
			var minion: Minion = _card as Minion
			AnimationManager._on_ronghed(minion, minion1, minion2)
			for _minion in CardUtils.get_desk_card(minion).get_minion_collection().get_array():
				AnimationManager._on_ronghed_minion(_minion) # 触发融合相关动画
	)
	minion1.add_animation(MinionAnimation.DeleteAnimation.new(minion1))
	minion2.add_animation(MinionAnimation.DeleteAnimation.new(minion2))

static func compute_total_stats(info: MinionInfo) -> Stats:
	if info.is_ronghe() == false:
		return info.get_stats()
	var stats: Stats = StatsUtils.copy(info.get_ronghe_info().get_stats())
	for baseInfo in info.get_base_info_array():
		stats.add_stats(baseInfo.get_stats())
	return stats

static func compute_total_shengdun(info: MinionInfo) -> void:
	var shengdun: bool = info.get_ronghe_info().get_keyword_info().is_shengdun()
	for baseInfo in info.get_base_info_array():
		shengdun = shengdun or baseInfo.get_keyword_info().is_shengdun()
	info.get_keyword_info()._shengdun = shengdun
	
static func compute_total_chaofeng(info: MinionInfo) -> void:
	var chaofeng: bool = info.get_ronghe_info().get_keyword_info().is_chaofeng()
	for baseInfo in info.get_base_info_array():
		chaofeng = chaofeng or baseInfo.get_keyword_info().is_chaofeng()
	info.get_keyword_info()._chaofeng = chaofeng
	
static func compute_total_fengnu(info: MinionInfo) -> void:
	var fengnu: bool = info.get_ronghe_info().get_keyword_info().is_fengnu()
	for baseInfo in info.get_base_info_array():
		fengnu = fengnu or baseInfo.get_keyword_info().is_fengnu()
	info.get_keyword_info()._fengnu = fengnu

static func is_alive(minion) -> bool:
	if is_instance_valid(minion) and minion is Minion:
		if minion.get_info().get_stats().get_health() > 0:
			return true
	return false

static func golden(info: MinionInfo) -> void:
	info.set_golden()
	info.get_stats().add_stats(info.get_origin_stats())

static func liejie(minion: Minion) -> void:
	# 裂解逻辑：复制相一份相同的随从信息，然后把属性值减半
	# 先从场上移除卡牌
	CardUtils.remove_card(minion)
	var new_minionInfo1: MinionInfo = minion.get_info().copy()
	var new_minionInfo2: MinionInfo = minion.get_info().copy()
	new_minionInfo1.set_uniqueId(DataManager.get_uniqueId())
	new_minionInfo2.set_uniqueId(DataManager.get_uniqueId())
	var new_stats: Stats = StatsUtils.max_stats(
		StatsUtils.half(minion.get_info().get_stats()),
		Stats.new(1, 1)
	)
	new_minionInfo1.set_stats(new_stats)
	new_minionInfo2.set_stats(new_stats)
	# 在添加卡牌前先处理裂解相关动画
	for _minion in CardUtils.get_desk_card(minion).get_minion_collection().get_array():
		AnimationManager._on_liejied_minion(_minion) # 触发裂解相关动画
	CardUtils.create_desk_card(
		new_minionInfo1,
		minion.global_position,
		minion
	)
	CardUtils.create_desk_card(
		new_minionInfo2,
		minion.global_position,
		minion
	)
	minion.add_animation(MinionAnimation.DeleteAnimation.new(minion))

static func set_golden(info: MinionInfo) -> void:
	info.set_golden()
	info.add_stats(
		info.get_origin_stats()
	)
	info.originStats.add_stats(
		info.get_origin_stats()
	)
		
static func set_golden_false(info: MinionInfo) -> void:
	info.set_golden_by_bool(false)
	info.originStats.sub_stats(
		StatsUtils.half(info.get_origin_stats())
	)
	info.sub_stats(
		info.get_origin_stats()
	)
		
static func set_golden_by_bool(info: MinionInfo, _golden: bool) -> void:
	match _golden:
		true:
			set_golden(info)
		false:
			set_golden_false(info)

static func get_xifu(minion: Minion, collection: MinionCollection) -> Minion:
	var minion_arr: Array[Minion] = collection.get_array()
	var nearest_minion: Minion = null
	var min_distance: float = INF
	var cili_threshold: float = 200
	
	for target in minion_arr:
		if target == minion:
			continue
		var dist: float = minion.global_position.distance_to(target.global_position)
		if dist < min_distance and dist <= cili_threshold:
			min_distance = dist
			nearest_minion = target
	
	return nearest_minion

static func xifu(ciliMinion: Minion, beXifuMinion: Minion) -> void:
	beXifuMinion.get_info().add_stats(ciliMinion.get_info().get_stats())
	# 合并关键词
	beXifuMinion.get_info().get_keyword_info().set_chaofeng(
		ciliMinion.get_info().get_keyword_info().is_chaofeng()
	)
	beXifuMinion.get_info().get_keyword_info().set_shengdun(
		ciliMinion.get_info().get_keyword_info().is_shengdun()
	)
	beXifuMinion.get_info().get_keyword_info().set_fengnu(
		ciliMinion.get_info().get_keyword_info().is_fengnu()
	)
	beXifuMinion.get_info().get_effect_collection().add_minion_effect(
		MinionEffectManager.match(
			ciliMinion.get_info().get_card_name()
		)
	)
