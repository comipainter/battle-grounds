extends Resource
class_name MinionClickInfo

func create(
	_able: bool = false,
	_sprite_path: String = "",
	_sprite_scale: Vector2 = Vector2(1, 1),
	_sprite_postion: Vector2 = Vector2.ZERO,
	_sprite_animation: MinionClickSpriteAnimation = null,
	_click_function: MinionClickFunction = null,
	_hit_function: MinionHitFunction = null
) -> void:
	clickAble = _able
	clickSpritePath = _sprite_path
	clickSpriteScale = _sprite_scale
	clickSpritePosition = _sprite_postion
	clickSpriteAnimation = _sprite_animation if _sprite_animation else MinionClickSpriteAnimation.new(null)
	clickFunction = _click_function if _click_function else MinionClickFunction.new(func(): pass)
	hitFunction = _hit_function if _hit_function else MinionHitFunction.new(func(): pass)
	
@export var clickAble: bool = false
func is_able() -> bool:
	return clickAble
func set_able(_able) -> void:
	clickAble = _able

@export var clickSpritePath: String = ""
func get_sprite_path() -> String:
	return clickSpritePath
func set_sprite_path(_path: String) -> void:
	clickSpritePath = _path

@export var clickSpriteScale: Vector2 = Vector2(1, 1)
func get_sprite_scale() -> Vector2:
	return clickSpriteScale
func set_sprite_scale(_scale: Vector2) -> void:
	clickSpriteScale = _scale
	
@export var clickSpritePosition: Vector2 = Vector2.ZERO
func get_sprite_position() -> Vector2:
	return clickSpritePosition
func set_sprite_position(_position: Vector2) -> void:
	clickSpritePosition = _position

@export var clickSpriteAnimation: MinionClickSpriteAnimation = MinionClickSpriteAnimation.new(null)
func get_sprite_animation() -> MinionClickSpriteAnimation:
	return clickSpriteAnimation
func set_sprite_animation(_animation: MinionClickSpriteAnimation) -> void:
	clickSpriteAnimation = _animation

@export var clickFunction: MinionClickFunction = MinionClickFunction.new(func(): pass)
func get_click_function() -> MinionClickFunction:
	return clickFunction
func set_click_function(_function: MinionClickFunction) -> void:
	clickFunction = _function

@export var hitFunction: MinionHitFunction = MinionHitFunction.new(func(): pass)
func get_hit_function() -> MinionHitFunction:
	return hitFunction
func set_hit_function(_function: MinionHitFunction) -> void:
	hitFunction = _function
