extends Control

class_name Clock

@export var dialSprite: Sprite2D
@export var pointerSprite: Sprite2D
var roundTime: int = 1 # 一圈需要的秒数，根据秒数决定旋转速度
var able: bool = false

var current_angle_deg: float = 0.0
var degrees_per_second: float = 0.0

var on_round_complete: Callable

func _ready() -> void:
	pointerSprite.rotation = 0.0

func start(roundTime, function) -> void:
	self.on_round_complete = function
	self.roundTime = roundTime
	current_angle_deg = 0.0
	pointerSprite.rotation = 0.0
	degrees_per_second = 360.0 / roundTime
	dialSprite.visible = true
	pointerSprite.visible = true
	able = true
	
func close() -> void:
	able = false

func _process(delta: float) -> void:
	if able:
		var delta_degrees: float = degrees_per_second * delta
		if current_angle_deg + delta_degrees > 360.0:
			self.on_round_complete.call()
		current_angle_deg += delta_degrees
		if current_angle_deg >= 360.0:
			current_angle_deg = fmod(current_angle_deg, 360.0)
		pointerSprite.rotation = deg_to_rad(current_angle_deg)
