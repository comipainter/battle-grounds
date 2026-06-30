extends Control
class_name PlayerWinsBarComponent

var _active_count: int = 0

func _ready() -> void:
	for bar in $HBoxContainer.get_children():
		bar.get_node("BarSprite").visible = false

func set_able(_able):
	self.visible = _able

func set_bar_num(num: int) -> void:
	var bars = $HBoxContainer.get_children()
	_active_count = mini(num, bars.size())
	for i in bars.size():
		bars[i].get_node("BarSprite").visible = i < _active_count

func add_bar() -> void:
	var bars = $HBoxContainer.get_children()
	if _active_count < bars.size():
		bars[_active_count].get_node("BarSprite").visible = true
		_active_count += 1
