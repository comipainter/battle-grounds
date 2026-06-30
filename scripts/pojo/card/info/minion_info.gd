extends CardInfo
class_name MinionInfo

func copy() -> MinionInfo:
	return duplicate(true)

# 逻辑方法
signal damage_taked
signal dead
func take_damage(_damage: int) -> void:
	if get_keyword_info().is_shengdun():
		get_keyword_info().set_shengdun(false)
		return
	sub_stats(Stats.new(0, _damage))
	damage_taked.emit()
	if get_stats().get_health() <= 0: # 判定死亡
		dead.emit()
	
@export var golden: bool = false
signal golden_changed
func is_golden() -> bool:
	return golden
func set_golden() -> void:
	golden = true
	golden_changed.emit()
func set_golden_by_bool(_golden: bool) -> void:
	golden = _golden
	golden_changed.emit()

@export var goldenDescription: String = ""
func set_goldenDescription(_description: String) -> void:
	goldenDescription = _description
func get_goldenDescription() -> String:
	return goldenDescription

@export var race: Race.Type = Race.Type.None
func set_race(_race: Race.Type) -> void:
	race = _race
func get_race() -> Race.Type:
	return race

@export var stats: Stats = Stats.new(1, 1)
func get_stats() -> Stats:
	return stats
signal stats_changed
func set_stats(_stats: Stats) -> void:
	#if is_ronghe(): ## 现在在静态类生产时计算了
		#get_ronghe_info().set_stats(_stats)
		#_stats = MinionUtils.compute_total_stats(self)
		#stats_changed.emit()
		#return
	stats = _stats
	stats_changed.emit()
func add_stats(_stats: Stats) -> void:
	if is_ronghe():
		get_ronghe_info().add_stats(_stats)
		stats = MinionUtils.compute_total_stats(self)
		stats_changed.emit()
		return
	stats.add_stats(_stats)
	stats_changed.emit()
func sub_stats(_stats: Stats) -> void:
	if is_ronghe():
		get_ronghe_info().sub_stats(_stats)
		stats = MinionUtils.compute_total_stats(self)
		stats_changed.emit()
		return
	stats.sub_stats(_stats)
	stats_changed.emit()
	
@export var originStats: Stats = Stats.new(1, 1)
func set_origin_stats(_stats: Stats) -> void:
	originStats = _stats
func get_origin_stats() -> Stats:
	return originStats

@export var keywordInfo: MinionKeywordInfo = MinionKeywordInfo.new()
func set_keyword_info(_keywordInfo: MinionKeywordInfo) -> void:
	keywordInfo.shengdun_changed.connect(MinionUtils.compute_total_shengdun.bind(self))
	keywordInfo.chaofeng_changed.connect(MinionUtils.compute_total_chaofeng.bind(self))
	keywordInfo.fengnu_changed.connect(MinionUtils.compute_total_fengnu.bind(self))
	keywordInfo = _keywordInfo
func get_keyword_info() -> MinionKeywordInfo:
	return keywordInfo

@export var clockInfo: MinionClockInfo = MinionClockInfo.new()
func set_clock_info(_clockInfo: MinionClockInfo) -> void:
	clockInfo = _clockInfo
func get_clock_info() -> MinionClockInfo:
	return clockInfo

@export var clickInfo: MinionClickInfo = MinionClickInfo.new()
func set_click_info(_clickInfo: MinionClickInfo) -> void:
	clickInfo = _clickInfo
func get_click_info() -> MinionClickInfo:
	return clickInfo

@export var counterInfo: MinionCounterInfo = MinionCounterInfo.new()
func get_counter_info() -> MinionCounterInfo:
	return counterInfo
signal counter_info_set
func set_counter_info(_counterInfo: MinionCounterInfo) -> void:
	counterInfo = _counterInfo
	counter_info_set.emit()
	
@export var boostCounterInfo: MinionBoostCounterInfo = MinionBoostCounterInfo.new()
func get_boost_counter_info() -> MinionBoostCounterInfo:
	return boostCounterInfo
func set_boost_counter_info(_boostCounterInfo: MinionBoostCounterInfo) -> void:
	boostCounterInfo = _boostCounterInfo

@export var minionEffectCollection: MinionEffectCollection = MinionEffectCollection.new()
func get_effect_collection() -> MinionEffectCollection:
	return minionEffectCollection
func set_effect_collection(_collection: MinionEffectCollection) -> void:
	minionEffectCollection = _collection
	
@export var baseMinionInfo: Array[MinionInfo] = []
func get_base_info_array() -> Array[MinionInfo]:
	return baseMinionInfo
func add_base_info(_info: MinionInfo):
	_info.stats_changed.connect(add_stats.bind(Stats.new(0, 0))) # 用0属性值触发计算
	_info.get_keyword_info().shengdun_changed.connect(MinionUtils.compute_total_shengdun.bind(self))
	_info.get_keyword_info().chaofeng_changed.connect(MinionUtils.compute_total_chaofeng.bind(self))
	_info.get_keyword_info().fengnu_changed.connect(MinionUtils.compute_total_fengnu.bind(self))
	_info.type = self.type
	_info.belong = self.belong
	baseMinionInfo.append(_info)
func set_base_info_array(_array: Array[MinionInfo]) -> void:
	baseMinionInfo = _array

@export var ronghe: bool = false
func is_ronghe() -> bool:
	return ronghe
func set_ronghe() -> void:
	ronghe = true

@export var ronghe_info: MinionInfo = null
func get_ronghe_info() -> MinionInfo:
	return ronghe_info
func set_ronghe_info(_info: MinionInfo) -> void:
	ronghe_info = _info

@export var cili: bool = false
func is_cili() -> bool:
	return cili
func set_cili(_cili: bool) -> void:
	cili = _cili
