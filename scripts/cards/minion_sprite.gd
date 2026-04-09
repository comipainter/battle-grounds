extends Sprite2D

@export var minionSprite2: Sprite2D
@export var texture_list: Array[Texture2D] = []
@export var cycle_duration: float = 4.0
@export var fade_time: float = 2

var current_index: int = 0
var tween: Tween
var tween2: Tween

var start: bool = false
var is_start: bool = false

func _ready():
	if texture_list.is_empty():
		return
	texture = texture_list[0]
	modulate.a = 1.0
	
	
func _process(delta: float) -> void:
	if start and not is_start:
		start = false
		is_start = true
		texture = texture_list[current_index]
		tween = create_tween()
		tween2 = minionSprite2.create_tween()
		
		tween.set_loops(-1)
		tween.tween_property(self, "modulate:a", 0.0, fade_time)
		tween.tween_callback(func():
			current_index += 1
			texture = texture_list[current_index%texture_list.size()])
		tween.tween_property(self, "modulate:a", 1.0, fade_time)
		
		minionSprite2.texture = texture_list[current_index]
		tween2.set_loops(-1)
		tween2.tween_property(minionSprite2, "modulate:a", 1.0, fade_time)
		tween2.tween_property(minionSprite2, "modulate:a", 0.0, fade_time)
		tween2.tween_callback(func():
			minionSprite2.texture = texture_list[(current_index + 1)%texture_list.size()])
