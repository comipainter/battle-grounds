extends MinionComponent
class_name MinionClickComponent

var info: MinionClickInfo = MinionClickInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info().get_click_info()
	minion.clicked.connect(_click)

@onready var clickSprite: Sprite2D = $ClickSprite
@onready var clickRegion: Control = $ClickRegion

var animationCollection: AnimationCollection = AnimationCollection.new()
var spriteAnimationCollection: AnimationCollection = AnimationCollection.new()

func use_info() -> void:
	if info.is_able():
		if info.get_sprite_path() != "":
			clickSprite.visible = true
			clickSprite.texture = load(info.get_sprite_path())
			clickSprite.scale = info.get_sprite_scale()
			clickSprite.position = info.get_sprite_position()
		
func close() -> void:
	clickSprite.visible = false
		
func _click(card: Card) -> void:
	if info.is_able():
		if spriteAnimationCollection.is_idle():
			var mouse_position = get_global_mouse_position() - self.global_position
			if info.get_click_function().run(minion, mouse_position) == "hit":
				minion.get_move_component().disable_drag()
				spriteAnimationCollection.add_animation(
					info.get_sprite_animation()
				)
				info.get_hit_function().run(minion, mouse_position)
				await GameManager.get_tree().create_timer(0.3).timeout
				minion.get_move_component().enable_drag()
			
func set_able(_able: bool) -> void:
	if _able:
		use_info()
	else:
		close()
