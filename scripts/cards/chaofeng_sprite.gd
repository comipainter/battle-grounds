extends Sprite2D

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops(-1)
	tween.tween_property(self, "modulate:a", 0.4, 1)
	tween.tween_property(self, "modulate:a", 1.0, 1)
