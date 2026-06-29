extends MinionComponent
class_name MinionStatsComponent

var info: MinionInfo = MinionInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info()
	info.stats_changed.connect(_display_stats)

@onready var healthSprite: Sprite2D = $Health/HealthSprite
@onready var healthLabel: Label = $Health/HealthLabelControl/HealthLabel
@onready var attackSprite: Sprite2D = $Attack/AttackSprite
@onready var attackLabel: Label = $Attack/AttackLabelControl/AttackLabel

@onready var attackLabelControl: Control = $Attack/AttackLabelControl
@onready var healthLabelControl: Control = $Health/HealthLabelControl

var currStats: Stats = Stats.new(0, 0)

func use_info() -> void:
	healthSprite.visible = true
	attackSprite.visible = true
	healthLabel.visible = true
	attackLabel.visible = true
	_display_stats()
	
func _display_stats() -> void:	
	_set_stats(info.get_stats())
	#healthLabel.text = str(info.get_stats().get_health())
	#attackLabel.text = str(info.get_stats().get_attack())
	set_color()
	
func set_color() -> void:
	if currStats.get_health() < info.get_origin_stats().get_health():
		healthLabel.add_theme_color_override("font_color", Color("#FF0000"))
	elif currStats.get_health() == info.get_origin_stats().get_health():
		healthLabel.add_theme_color_override("font_color", Color("#FFFFFF"))
	else:
		healthLabel.add_theme_color_override("font_color", Color("#00FF00"))
	
	if currStats.get_attack() < info.get_origin_stats().get_attack():
		attackLabel.add_theme_color_override("font_color", Color("#FF0000"))
	elif currStats.get_attack() == info.get_origin_stats().get_attack():
		attackLabel.add_theme_color_override("font_color", Color("#FFFFFF"))
	else:
		attackLabel.add_theme_color_override("font_color", Color("#00FF00"))
		
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		healthSprite.visible = false
		healthLabel.visible = false
		attackSprite.visible = false
		attackLabel.visible = false


var _stats_queue: Array[Stats] = []
var _is_animating: bool = false

func is_idle() -> bool:
	return !_is_animating and _stats_queue.is_empty()

func _set_stats(new_stats: Stats) -> void:
	_stats_queue.append(new_stats)
	_process_queue()
	set_color()


func _process_queue() -> void:
	if _is_animating or _stats_queue.is_empty():
		return

	_is_animating = true
	var new_stats: Stats = _stats_queue.pop_front()

	if currStats == new_stats:
		if _stats_queue.is_empty():
			_is_animating = false
		else:
			_process_queue()
		return
	
	healthLabel.text = str(new_stats.get_health())
	attackLabel.text = str(new_stats.get_attack())
	if StatsUtils.equal(currStats, Stats.new(0, 0)):
		currStats = StatsUtils.copy(new_stats)
		if _stats_queue.is_empty():
			_is_animating = false
		else:
			_process_queue()
		return
	currStats = StatsUtils.copy(new_stats)
	
	var origin_time := 0.12 # 0.12
	var speed_multiplier := 1.0 + _stats_queue.size() * 0.5
	var scale_duration := origin_time / speed_multiplier
	var alpha_duration := origin_time / speed_multiplier
	
	await Utils.run_and_wait_all(
		[
			_animate.bind(healthLabelControl,  speed_multiplier, scale_duration, alpha_duration),
			_animate.bind(attackLabelControl,  speed_multiplier, scale_duration, alpha_duration),
		]
	)
	set_color()
	_on_animation_finished()

func _animate(control: Control, speed_multiplier, scale_duration, alpha_duration) -> Signal:
	var tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2(1.2, 1.2), scale_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, scale_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "modulate:a", 0.7, alpha_duration).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "modulate:a", 1.0, alpha_duration).set_ease(Tween.EASE_IN)
	return tween.finished


func _on_animation_finished() -> void:
	_is_animating = false
	_process_queue()
