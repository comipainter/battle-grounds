extends Control
class_name AreaComponent

signal area_mouse_entered
signal area_mouse_exited
signal area_mouse_down
signal area_mouse_up

@onready var collisionShape: CollisionShape2D = $Area2D/CollisionShape2D

func is_inside(_position: Vector2) -> bool:
	return ShapeUtils.is_point_in_rect_area(
		_position,
		collisionShape
	)

@onready var area: Area2D = $Area2D

func _on_area_2d_mouse_entered() -> void:
	area_mouse_entered.emit()

func _on_area_2d_mouse_exited() -> void:
	area_mouse_exited.emit()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_inside(get_global_mouse_position()):
				area_mouse_down.emit()
		else:
			if is_inside(get_global_mouse_position()):
				area_mouse_up.emit()

func able() -> void:
	area.monitoring = true
	
func disable() -> void:
	area.monitoring = false
