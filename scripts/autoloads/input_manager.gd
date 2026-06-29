extends Control
class_name InputManager

#  检测鼠标是否处于拖拽状态
var mouse_pressed = false  # 用于记录当前是否处于拖拽状态

func is_mouse_pressed() -> bool:
	return mouse_pressed

signal mouse_left_down
signal mouse_left_up

func _input(event):
	# 监听鼠标左键的按下和释放
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_pressed = true
			mouse_left_down.emit()
		else:
			mouse_pressed = false
			mouse_left_up.emit()
