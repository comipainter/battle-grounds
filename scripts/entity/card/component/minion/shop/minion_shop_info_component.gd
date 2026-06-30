extends MinionComponent
class_name MinionShopInfoComponent

@onready var backgroundComponent: MinionBackgroundComponent = $Background
@onready var statsComponent: MinionStatsComponent = $Stats
@onready var keywordComponent: MinionKeywordComponent = $Keyword
@onready var levelComponent: CardLevelComponent = $Level

func set_minion(_minion: Minion):
	minion = _minion
	backgroundComponent.set_minion(minion)
	statsComponent.set_minion(minion)
	keywordComponent.set_minion(minion)
	levelComponent.set_level(minion.get_info().get_level())

func use_info() -> void:
	backgroundComponent.use_info()
	statsComponent.use_info()
	keywordComponent.use_info()
	levelComponent.use_info()

var able: bool = true
func set_able(_able) -> void:
	if able != _able:
		backgroundComponent.set_able(_able)
		statsComponent.set_able(_able)
		keywordComponent.set_able(_able)
		levelComponent.set_able(_able)
		able = _able
	
