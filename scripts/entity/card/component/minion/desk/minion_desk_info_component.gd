extends MinionComponent
class_name MinionDeskInfoComponent

@onready var backgroundComponent: MinionBackgroundComponent = $Background
@onready var clickComponent: MinionClickComponent = $Click
@onready var clockComponent: MinionClockComponent = $Clock
@onready var statsComponent: MinionStatsComponent = $Stats
@onready var counterComponent: MinionCounterComponent = $Counter
@onready var keywordComponent: MinionKeywordComponent = $Keyword
@onready var boostCounterComponent: MinionBoostCounterComponent = $BoostCounter

func get_background_component() -> MinionBackgroundComponent:
	return backgroundComponent

func get_click_component() -> MinionClickComponent:
	return clickComponent

func get_clock_component() -> MinionClockComponent:
	return clockComponent

func get_stats_component() -> MinionStatsComponent:
	return statsComponent

func get_counter_component() -> MinionCounterComponent:
	return counterComponent

func get_keyword_component() -> MinionKeywordComponent:
	return keywordComponent

func get_boost_counter_component() -> MinionBoostCounterComponent:
	return boostCounterComponent

func set_minion(_minion: Minion):
	minion = _minion
	backgroundComponent.set_minion(minion)
	clickComponent.set_minion(minion)
	clockComponent.set_minion(minion)
	statsComponent.set_minion(minion)
	counterComponent.set_minion(minion)
	keywordComponent.set_minion(minion)
	boostCounterComponent.set_minion(minion)
	
	# 信号分布
	minion.get_info().counter_info_set.connect(counterComponent.use_info)
	minion.get_info().golden_changed.connect(use_info)

func use_info() -> void:
	backgroundComponent.use_info()
	clickComponent.use_info()
	clockComponent.use_info()
	statsComponent.use_info()
	counterComponent.use_info()
	keywordComponent.use_info()
	boostCounterComponent.use_info()

var able: bool = true
func set_able(_able) -> void:
	if able != _able:
		backgroundComponent.set_able(_able)
		clickComponent.set_able(_able)
		clockComponent.set_able(_able)
		statsComponent.set_able(_able)
		counterComponent.set_able(_able)
		keywordComponent.set_able(_able)
		boostCounterComponent.set_able(_able)
		able = _able
		
