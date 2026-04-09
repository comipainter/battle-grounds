extends Control
class_name PaiDuiYuanSu_Particles

## 彩色烟花粒子效果
## 直接在位置处爆炸，包含主爆炸、闪光和次级爆炸效果
## 使用 GPUParticles2D 实现高性能烟花特效

## 粒子节点引用
@export var main_particles: GPUParticles2D        # 主爆炸粒子
@export var sparkle_particles: GPUParticles2D     # 闪光粒子
@export var sub_emitter: GPUParticles2D           # 次级爆炸发射器

## 烟花参数
@export var auto_cleanup: bool = true             # 是否自动清理
@export var particle_scale: float = 1.0           # 粒子缩放（移动端可降低）

## 状态
var is_emitting: bool = false

## 动态创建的次级爆炸节点列表
var _sub_particles_list: Array[GPUParticles2D] = []

## 材质缓存
var _main_material: ParticleProcessMaterial
var _sparkle_material: ParticleProcessMaterial
var _sub_material: ParticleProcessMaterial

## 彩色烟花颜色方案
var firework_colors: Array[Gradient] = []

## 烟花总生命周期（1.5秒）
const TOTAL_LIFETIME: float = 1.5

func _ready() -> void:
	_setup_materials()
	_setup_color_gradients()
	_configure_particles()
	_adjust_for_platform()

func _setup_materials() -> void:
	# 主爆炸材质
	if main_particles:
		_main_material = main_particles.process_material
		if not _main_material:
			_main_material = ParticleProcessMaterial.new()
			main_particles.process_material = _main_material

	# 闪光材质
	if sparkle_particles:
		_sparkle_material = sparkle_particles.process_material
		if not _sparkle_material:
			_sparkle_material = ParticleProcessMaterial.new()
			sparkle_particles.process_material = _sparkle_material

	# 次级爆炸材质
	if sub_emitter:
		_sub_material = sub_emitter.process_material
		if not _sub_material:
			_sub_material = ParticleProcessMaterial.new()
			sub_emitter.process_material = _sub_material

func _setup_color_gradients() -> void:
	# 创建多个彩色渐变方案（带透明度淡出）
	var gradients_data = [
		# 方案1: 红橙黄 - 温暖火焰色
		[Color.RED, Color.ORANGE, Color.YELLOW, Color(1.0, 1.0, 0.5, 0.0)],
		# 方案2: 蓝青绿 - 冷色调
		[Color.BLUE, Color.CYAN, Color.SPRING_GREEN, Color(0.0, 1.0, 0.8, 0.0)],
		# 方案3: 粉紫蓝 - 梦幻色
		[Color.PINK, Color.VIOLET, Color.BLUE, Color(0.5, 0.0, 1.0, 0.0)],
		# 方案4: 金黄橙 - 金色烟花
		[Color.GOLD, Color.YELLOW, Color.ORANGE, Color(1.0, 0.8, 0.0, 0.0)],
		# 方案5: 绿青蓝 - 翡翠色
		[Color.LIME_GREEN, Color.CYAN, Color.DEEP_SKY_BLUE, Color(0.0, 0.75, 1.0, 0.0)],
		# 方案6: 白银闪光
		[Color.WHITE, Color.SILVER, Color.LIGHT_GRAY, Color(0.8, 0.8, 0.8, 0.0)],
		# 方案7: 彩虹渐变
		[Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.VIOLET, Color(0.5, 0.0, 1.0, 0.0)],
	]

	firework_colors.clear()
	for colors in gradients_data:
		var gradient = Gradient.new()
		for i in range(colors.size()):
			gradient.add_point(float(i) / float(colors.size() - 1), colors[i])
		firework_colors.append(gradient)

func _configure_particles() -> void:
	_configure_main_particles()
	_configure_sparkle_particles()
	_configure_sub_emitter()

func _configure_main_particles() -> void:
	if not main_particles or not _main_material:
		return

	# 主爆炸配置
	main_particles.one_shot = true
	main_particles.amount = 100
	main_particles.lifetime = 0.8
	main_particles.explosiveness = 0.95
	main_particles.randomness = 0.5

	# 使用球形发射获得更好的3D效果
	_main_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_main_material.emission_sphere_radius = 8.0 * particle_scale

	# 全方向扩散
	_main_material.direction = Vector3(0, 0, 0)
	_main_material.spread = 180.0

	# 速度设置
	_main_material.initial_velocity_min = 300.0 * particle_scale
	_main_material.initial_velocity_max = 600.0 * particle_scale

	# 重力和阻尼
	_main_material.gravity = Vector3(0, 150, 0)
	_main_material.damping_min = 3.0
	_main_material.damping_max = 6.0

	# 缩放
	_main_material.scale_min = 2.0 * particle_scale
	_main_material.scale_max = 5.0 * particle_scale

	# 随机性
	_main_material.lifetime_randomness = 0.3
	_main_material.angular_velocity_min = -360.0
	_main_material.angular_velocity_max = 360.0

func _configure_sparkle_particles() -> void:
	if not sparkle_particles or not _sparkle_material:
		return

	# 闪光配置 - 小而亮的闪烁点
	sparkle_particles.one_shot = true
	sparkle_particles.amount = 50
	sparkle_particles.lifetime = 0.5
	sparkle_particles.explosiveness = 0.9

	# 闪光颜色 - 白色到透明
	var sparkle_gradient = Gradient.new()
	sparkle_gradient.add_point(0.0, Color.WHITE)
	sparkle_gradient.add_point(0.3, Color(1.0, 1.0, 0.8, 0.9))
	sparkle_gradient.add_point(1.0, Color(1.0, 1.0, 0.5, 0.0))
	_sparkle_material.color_ramp = _create_gradient_texture(sparkle_gradient)

	# 发射形状
	_sparkle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_sparkle_material.emission_sphere_radius = 12.0 * particle_scale

	# 方向和速度
	_sparkle_material.direction = Vector3(0, 0, 0)
	_sparkle_material.spread = 180.0
	_sparkle_material.initial_velocity_min = 80.0 * particle_scale
	_sparkle_material.initial_velocity_max = 200.0 * particle_scale

	# 重力
	_sparkle_material.gravity = Vector3(0, 50, 0)

	# 缩放 - 小而亮
	_sparkle_material.scale_min = 0.5 * particle_scale
	_sparkle_material.scale_max = 1.5 * particle_scale
	_sparkle_material.lifetime_randomness = 0.4

func _configure_sub_emitter() -> void:
	if not sub_emitter or not _sub_material:
		return

	# 次级爆炸配置 - 更小更快的粒子
	sub_emitter.one_shot = true
	sub_emitter.amount = 40
	sub_emitter.lifetime = 0.6
	sub_emitter.explosiveness = 0.9

	# 发射形状
	_sub_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_sub_material.emission_sphere_radius = 3.0 * particle_scale

	# 方向和速度
	_sub_material.direction = Vector3(0, 0, 0)
	_sub_material.spread = 180.0
	_sub_material.initial_velocity_min = 180.0 * particle_scale
	_sub_material.initial_velocity_max = 350.0 * particle_scale

	# 重力和阻尼
	_sub_material.gravity = Vector3(0, 100, 0)
	_sub_material.damping_min = 2.5
	_sub_material.damping_max = 5.0

	# 缩放
	_sub_material.scale_min = 1.0 * particle_scale
	_sub_material.scale_max = 2.5 * particle_scale

func _create_gradient_texture(gradient: Gradient) -> GradientTexture1D:
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture

func _adjust_for_platform() -> void:
	# 根据平台调整粒子数量以保证性能
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		particle_scale = 0.6
		if main_particles:
			main_particles.amount = int(main_particles.amount * 0.5)
		if sparkle_particles:
			sparkle_particles.amount = int(sparkle_particles.amount * 0.5)
		if sub_emitter:
			sub_emitter.amount = int(sub_emitter.amount * 0.5)

## 发射烟花（直接在当前位置爆炸）
func emit() -> void:
	_trigger_explosion()

## 触发爆炸效果
func _trigger_explosion() -> void:
	is_emitting = true

	# 随机选择颜色方案
	var color_gradient = firework_colors[randi() % firework_colors.size()]
	var color_texture = _create_gradient_texture(color_gradient)

	# 应用颜色到主爆炸
	if _main_material:
		_main_material.color_ramp = color_texture

	# 触发主爆炸
	if main_particles:
		main_particles.restart()
		main_particles.emitting = true

	# 触发闪光
	if sparkle_particles:
		sparkle_particles.restart()
		sparkle_particles.emitting = true

	# 延迟触发次级爆炸
	get_tree().create_timer(0.05).timeout.connect(_trigger_sub_explosions)

func _trigger_sub_explosions() -> void:
	if not sub_emitter:
		_schedule_cleanup()
		return

	# 在爆炸位置周围创建多个次级爆炸点
	var sub_offsets := [
		Vector2(-50, -50),
		Vector2(50, -50),
		Vector2(-50, 50),
		Vector2(50, 50),
		Vector2(0, -60),
		Vector2(0, 60),
	]

	# 为每个次级爆炸创建独立的粒子节点
	for i in range(sub_offsets.size()):
		var offset = sub_offsets[i]
		var delay = i * 0.015  # 错开时间
		get_tree().create_timer(delay).timeout.connect(
			func(): _create_and_trigger_sub(offset)
		)

	_schedule_cleanup()

func _create_and_trigger_sub(offset: Vector2) -> void:
	if not sub_emitter or not is_emitting:
		return

	# 创建新的次级爆炸粒子节点
	var new_sub := GPUParticles2D.new()
	new_sub.process_material = sub_emitter.process_material.duplicate()
	new_sub.texture = sub_emitter.texture
	new_sub.one_shot = true
	new_sub.amount = sub_emitter.amount
	new_sub.lifetime = sub_emitter.lifetime
	new_sub.explosiveness = sub_emitter.explosiveness
	new_sub.position = offset

	# 随机选择颜色
	var sub_color = firework_colors[randi() % firework_colors.size()]
	new_sub.process_material.color_ramp = _create_gradient_texture(sub_color)

	add_child(new_sub)
	_sub_particles_list.append(new_sub)

	# 触发爆炸
	new_sub.emitting = true

	# 粒子播放完毕后自动删除
	await get_tree().create_timer(new_sub.lifetime).timeout
	if is_instance_valid(new_sub):
		_sub_particles_list.erase(new_sub)
		new_sub.queue_free()

func _schedule_cleanup() -> void:
	if not auto_cleanup:
		return

	await get_tree().create_timer(TOTAL_LIFETIME).timeout
	_cleanup()

func _cleanup() -> void:
	is_emitting = false
	_stop_all_particles()

	# 清理动态创建的次级爆炸节点
	for sub in _sub_particles_list:
		if is_instance_valid(sub):
			sub.queue_free()
	_sub_particles_list.clear()

func _stop_all_particles() -> void:
	if main_particles:
		main_particles.emitting = false
	if sparkle_particles:
		sparkle_particles.emitting = false
	if sub_emitter:
		sub_emitter.emitting = false

## 停止所有粒子
func stop() -> void:
	_cleanup()

## 设置自定义颜色方案
func set_custom_colors(colors: Array[Color]) -> void:
	var gradient = Gradient.new()
	# 确保最后一个颜色有透明度淡出
	var last_color = colors[-1]
	if last_color.a > 0:
		colors.append(Color(last_color.r, last_color.g, last_color.b, 0.0))

	for i in range(colors.size()):
		gradient.add_point(float(i) / float(colors.size() - 1), colors[i])

	firework_colors.clear()
	firework_colors.append(gradient)

## 设置粒子缩放（用于性能调整）
func set_particle_scale(scale: float) -> void:
	particle_scale = scale
	_configure_particles()

## 获取烟花总生命周期
func get_total_lifetime() -> float:
	return TOTAL_LIFETIME
