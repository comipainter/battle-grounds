extends Component
class_name CardMoveComponent

static func get_component_name() -> String:
	return "CardMoveComponent"

@onready var _owner_card: Card = get_parent()

@export var damping: float = 0.2
@export var stiffness: float = 700.0
@export var snap_threshold: float = 2.0
@export var rotation_speed: float = 10.0  ## rotation插值速度

@export var max_speed: float = 10000.0  ## 最大移动速度限制

func set_max_speed(_speed: float) -> void:
	max_speed = _speed

func set_damping(_damping: float) -> void:
	damping = _damping

func set_stiffness(_stiffness: float) -> void:
	stiffness = _stiffness

var moveState: CardMoveState = CardMoveState.new()
func _set_move() -> void:
	moveState.set_move()
func _set_stop() -> void:
	moveState.set_stop()
func is_move() -> bool:
	return moveState.is_move()
func is_stop() -> bool:
	return moveState.is_stop()

var behaviorMode: CardBehaviorMode = CardBehaviorMode.new()
func set_follow() -> void:
	if _can_follow == false:
		push_warning("set card behavior follow after disable follow")
	if is_drag():
		end_drag.emit()
	behaviorMode.set_follow()
func set_drag() -> void:
	if _can_drag == false:
		push_warning("set card behavior darg after disable drag")
	if is_drag() == false:
		start_drag.emit()
	behaviorMode.set_drag()
func set_behavior_none() -> void:
	behaviorMode.set_none()
func is_follow() -> bool:
	return behaviorMode.is_follow()
func is_drag() -> bool:
	return behaviorMode.is_drag()
func is_behavior_none() -> bool:
	return behaviorMode.is_none()

var velocity: Vector2 = Vector2.ZERO

var _can_follow: bool = true
var _can_drag: bool = true
func enable_follow() -> void:
	_can_follow = true
func enable_drag() -> void:
	_can_drag = true
func disable_follow() -> void:
	_can_follow = false
func disable_drag() -> void:
	_can_drag = false

var _follow_target: Control = null
func set_target(target: Control) -> void:
	_follow_target = target
func get_target() -> Control:
	return _follow_target

func _ready() -> void:
	_owner_card = get_parent() as Card

signal start_drag
signal dragging
signal end_drag

func _process(delta: float) -> void:
	if is_drag() and _can_drag:
		_set_move()
		_process_drag()
		dragging.emit()
	elif is_follow() and _can_follow:
		if is_instance_valid(_follow_target):
			_set_move()
			_process_follow(delta)
		else:
			push_error("follow node not exist")
	elif is_behavior_none():
		velocity = Vector2.ZERO
		_set_stop()
		if is_instance_valid(_follow_target) and _can_follow:
			_process_follow(delta)

func _process_drag() -> void:
	var target_pos = _owner_card.get_global_mouse_position()
	_owner_card.global_position = _owner_card.global_position.lerp(target_pos, 0.4)
	# drag时rotation立刻归0
	_owner_card.rotation = 0.0
	
func _process_follow(delta: float) -> void:
	var target_pos = _follow_target.global_position
	var displacement = target_pos - _owner_card.global_position
	var distance = displacement.length()

	if distance < snap_threshold:
		if is_move():
			_owner_card.global_position = target_pos
			set_behavior_none()
	else:
		var force = displacement * stiffness
		velocity += force * delta
		velocity *= (1.0 - damping)
		
		# --- 限制最大速度 ---
		if velocity.length() > max_speed:
			velocity = velocity.limit_length(max_speed)
		
		_owner_card.global_position += velocity * delta

	# rotation逐渐插值到target的rotation
	var target_rotation = _follow_target.rotation
	_owner_card.rotation = lerp(_owner_card.rotation, target_rotation, rotation_speed * delta)

func is_idle() -> bool:
	if is_stop() and is_behavior_none():
		# 额外检查一遍距离，防止target的位置刚变的情况
		var target_pos = _follow_target.global_position
		var displacement = target_pos - _owner_card.global_position
		var distance = displacement.length()
		if distance < snap_threshold:
			return true
	# 如果双禁止也要判定idle
	if _can_drag == false and _can_follow == false:
		return true
	return false
