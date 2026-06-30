extends Node2D
class_name CardInteractionComponent

static func get_component_name() -> String:
	return "CardInteractionComponent"
	
@onready var card: Card = get_parent()

# 输入捕获
@onready var areaComponent: AreaComponent = $Area # 采用区域模式捕获
@onready var button: Button = $Button

# 仅针对按钮模式的设定
func set_input_stop() -> void:
	button.mouse_filter = Control.MOUSE_FILTER_STOP
func set_input_pass() -> void:
	button.mouse_filter = Control.MOUSE_FILTER_PASS

# 信号
signal hover_started
signal hover_ended
signal clicked
signal mouse_entered
signal mouse_exited
signal mouse_down
signal mouse_up

# 区域模式捕获逻辑
func _ready() -> void:
	#areaComponent.area_mouse_down.connect(
		#func():
			#if areaComponent.is_inside(get_global_mouse_position()):
				#on_mouse_down()
				#clicked.emit()
				#mouse_down.emit()
	#)
	#areaComponent.area_mouse_up.connect(
		#func():
			#if areaComponent.is_inside(get_global_mouse_position()):
				#on_mouse_up()
				#mouse_up.emit()
	#)
	#areaComponent.area_mouse_entered.connect(
		#func():
			#if GameManager.get_input_manager().is_mouse_pressed() == false:
				#on_mouse_entered()
				#mouse_entered.emit()
	#)
	#areaComponent.area_mouse_exited.connect(
		#func():
			#if GameManager.get_input_manager().is_mouse_pressed() == false:
				#on_mouse_exited()
				#mouse_exited.emit()
	#)
	
	# 按钮模式捕获逻辑
	button.button_down.connect(
		func():
			if areaComponent.is_inside(get_global_mouse_position()):
				on_mouse_down()
				clicked.emit()
				mouse_down.emit()
	)
	button.button_up.connect(
		func():
			if areaComponent.is_inside(get_global_mouse_position()):
				on_mouse_up()
				mouse_up.emit()
	)
	button.mouse_entered.connect(
		func():
			if GameManager.get_input_manager().is_mouse_pressed() == false:
				on_mouse_entered()
				mouse_entered.emit()
	)
	button.mouse_exited.connect(
		func():
			if GameManager.get_input_manager().is_mouse_pressed() == false:
				on_mouse_exited()
				mouse_exited.emit()
	)



@export var hover_duration_ms: int = 500

var is_hovering: bool = false
var is_entered: bool = false

var _hover_start_time: int = 0

func on_mouse_entered() -> void:
	# 悬停相关
	is_entered = true
	_hover_start_time = Time.get_ticks_msec()
	_start_hover_timer()
		
func on_mouse_exited() -> void:
	if is_hovering:
		is_hovering = false
		hover_ended.emit()
	is_entered = false
	

func on_mouse_down() -> void:
	if is_hovering:
		is_hovering = false
		hover_ended.emit()
	is_entered = false
	
func on_mouse_up() -> void:
	pass
	
func _start_hover_timer() -> void:
	await card.get_tree().create_timer(hover_duration_ms / 1000.0).timeout
	if is_entered and not is_hovering:
		is_hovering = true
		hover_started.emit()
