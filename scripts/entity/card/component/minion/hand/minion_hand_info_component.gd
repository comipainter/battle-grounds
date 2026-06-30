extends MinionComponent
class_name MinionHandInfoComponent

@onready var backgroundComponent: MinionHandBackgroundComponent = $Background
@onready var descriptionComponent: MinionHandDescriptionComponent = $Description
@onready var nameComponent: MinionHandNameComponent = $Name
@onready var statsComponent: MinionStatsComponent = $Stats
@onready var raceComponent: MinionHandRaceComponent = $Race
@onready var levelComponent: CardLevelComponent = $Level

func get_background_component() -> MinionHandBackgroundComponent:
	return backgroundComponent

func get_description_component() -> MinionHandDescriptionComponent:
	return descriptionComponent

func get_name_component() -> MinionHandNameComponent:
	return nameComponent

func get_stats_component() -> MinionStatsComponent:
	return statsComponent

func get_race_component() -> MinionHandRaceComponent:
	return raceComponent

func get_level_component() -> CardLevelComponent:
	return levelComponent

func set_minion(_minion: Minion):
	minion = _minion
	backgroundComponent.set_minion(minion)
	descriptionComponent.set_minion(minion)
	nameComponent.set_minion(minion)
	statsComponent.set_minion(minion)
	raceComponent.set_minion(minion)
	levelComponent.set_level(minion.get_info().get_level())
	
func use_info() -> void:
	if able:
		backgroundComponent.use_info()
		descriptionComponent.use_info()
		nameComponent.use_info()
		statsComponent.use_info()
		raceComponent.use_info()
		levelComponent.use_info()

var able: bool = true
func set_able(_able) -> void:
	if able != _able:
		backgroundComponent.set_able(_able)
		descriptionComponent.set_able(_able)
		nameComponent.set_able(_able)
		statsComponent.set_able(_able)
		raceComponent.set_able(_able)
		levelComponent.set_able(_able)
		able = _able
