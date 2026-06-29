extends MinionComponent
class_name MinionHandStatsComponent

var info: MinionInfo = MinionInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info()
	info.stats_changed.connect((func():
		healthLabel.text = str(currStats.get_health())
		attackLabel.text = str(currStats.get_attack())
	))

@onready var healthSprite: Sprite2D = $Health/HealthSprite
@onready var healthLabel: Label = $Health/HealthLabel
@onready var attackSprite: Sprite2D = $Attack/AttackSprite
@onready var attackLabel: Label = $Attack/AttackLabel

var currStats: Stats = Stats.new(0, 0)

func use_info() -> void:
	healthSprite.visible = true
	attackSprite.visible = true
	healthLabel.visible = true
	attackLabel.visible = true
	if currStats != info.get_stats():
		currStats.set_stats(info.get_stats())
		healthLabel.text = str(currStats.get_health())
		attackLabel.text = str(currStats.get_attack())
		
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		healthSprite.visible = false
		healthLabel.visible = false
		attackSprite.visible = false
		attackLabel.visible = false
