extends MinionComponent
class_name MinionClockComponent

var info: MinionClockInfo = MinionClockInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info().get_clock_info()
	
	# 设置初始角度
	pointerSprite.rotation = deg_to_rad(info.get_curr_degree())

@onready var dialSprite: Sprite2D = $DialSprite
@onready var pointerSprite: Sprite2D = $PointerSprite

var degrees_per_second: float = 0.0

signal on_round_complete

func use_info() -> void:
	if info.is_able():
		start(info.get_clock_round_time())
	else:
		close()

func run(_roundTime: float) -> void:
	if info.is_able():
		if info.is_stop():
			goon()
	start(_roundTime)
	info.set_able(true)
	info.set_stop(true)

func start(_roundTime: float) -> void:
	info.set_clock_round_time(_roundTime)
	info.set_curr_degree(info.get_curr_degree())
	pointerSprite.rotation = deg_to_rad(info.get_curr_degree())
	degrees_per_second = 360.0 / info.get_clock_round_time()
	dialSprite.visible = true
	pointerSprite.visible = true
	info.set_able(true)
	info.set_stop(false)

func close() -> void:
	info.set_able(false)
	dialSprite.visible = false
	pointerSprite.visible = false

func stop() -> void:
	info.set_stop(true)

func goon() -> void:
	info.set_stop(false)
	
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		close()

func _process(delta: float) -> void:
	if info.is_able():
		if not info.is_stop():
			var delta_degrees: float = degrees_per_second * delta
			if info.get_curr_degree() + delta_degrees > 360.0:
				info.get_clock_function().run(minion)
				on_round_complete.emit()
			info.set_curr_degree(info.get_curr_degree() + delta_degrees)
			if info.get_curr_degree() >= 360.0:
				info.set_curr_degree(fmod(info.get_curr_degree(), 360.0))
			pointerSprite.rotation = deg_to_rad(info.get_curr_degree())
