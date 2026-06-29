extends Component
class_name CardShadowComponent

@onready var _shadow_sprite: Sprite2D = $ShadowSprite
@onready var _material: ShaderMaterial = _shadow_sprite.material

## 阴影颜色
@export var shadow_color: Color = Color(0, 0, 0, 0.5)

## 阴影距离系数
@export var shadow_distance: float = 15/500.0
@export var base_offset: float = 3.0

enum ShadowLevel{
	Idle,
	Drag
}
var shadow_level: float = 1
func set_shadow_level(level: ShadowLevel):
	match level:
		ShadowLevel.Idle:
			shadow_level = 1
		ShadowLevel.Drag:
			shadow_level = 1.5

## 基础位置
var _base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if is_instance_valid(_shadow_sprite):
		_base_position = _shadow_sprite.position
	_update_shadow_style()

func _process(_delta: float) -> void:
	_update_shadow_position()

## 根据光源位置更新阴影偏移
func _update_shadow_position() -> void:
	if not is_instance_valid(_shadow_sprite):
		return

	# 计算光源到卡牌的方向向量
	var light_dir = Light.Lightpoint - self.global_position

	# 根据光源方向设置阴影偏移（阴影在光源相反方向）
	var shadow_offset = Vector2.ZERO
	if light_dir.length() > 0:
		shadow_offset = -light_dir.normalized() *\
		 (shadow_distance * light_dir.length() + base_offset) *\
		 shadow_level

	_shadow_sprite.position = _base_position + shadow_offset

## 更新阴影样式
func _update_shadow_style() -> void:
	if not is_instance_valid(_material):
		return

	_material.set_shader_parameter("shadow_color", shadow_color)

## 设置阴影颜色
func set_shadow_color(color: Color) -> void:
	shadow_color = color
	_update_shadow_style()

## 设置阴影距离
func set_shadow_distance(distance: float) -> void:
	shadow_distance = distance

func set_shadow_sprite(_texture: Texture, _scale: Vector2) -> void:
	_shadow_sprite.texture = _texture
	_shadow_sprite.scale = _scale
