extends Control
class_name YeHuoYuanSu_Particles

## 喷火粒子效果
## 从start_position喷射火焰到end_position，最终覆盖目标区域
## 使用 GPUParticles2D 实现高性能火焰特效

## 粒子节点引用
@export var main_fire_particles: GPUParticles2D      # 主火焰粒子
@export var spark_particles: GPUParticles2D          # 火花粒子
@export var smoke_particles: GPUParticles2D          # 烟雾粒子
@export var glow_particles: GPUParticles2D           # 发光粒子

## 火焰参数
@export var auto_cleanup: bool = true                # 是否自动清理
@export var particle_scale: float = 1.0              # 粒子缩放
@export var fire_intensity: float = 1.0              # 火焰强度

## 状态
var is_emitting: bool = false
var _start_position: Vector2 = Vector2.ZERO
var _end_position: Vector2 = Vector2.ZERO
var _fire_direction: Vector2 = Vector2.RIGHT
var _fire_distance: float = 100.0

## 材质缓存
var _main_material: ParticleProcessMaterial
var _spark_material: ParticleProcessMaterial
var _smoke_material: ParticleProcessMaterial
var _glow_material: ParticleProcessMaterial

## 火焰颜色渐变
var fire_gradient: Gradient

## 火焰总生命周期
const TOTAL_LIFETIME: float = 2.0

func _ready() -> void:
	_setup_materials()
	_setup_fire_gradient()
	_configure_particles()
	_adjust_for_platform()

func _setup_materials() -> void:
	# 主火焰材质
	if main_fire_particles:
		_main_material = main_fire_particles.process_material
		if not _main_material:
			_main_material = ParticleProcessMaterial.new()
			main_fire_particles.process_material = _main_material

	# 火花材质
	if spark_particles:
		_spark_material = spark_particles.process_material
		if not _spark_material:
			_spark_material = ParticleProcessMaterial.new()
			spark_particles.process_material = _spark_material

	# 烟雾材质
	if smoke_particles:
		_smoke_material = smoke_particles.process_material
		if not _smoke_material:
			_smoke_material = ParticleProcessMaterial.new()
			smoke_particles.process_material = _smoke_material

	# 发光材质
	if glow_particles:
		_glow_material = glow_particles.process_material
		if not _glow_material:
			_glow_material = ParticleProcessMaterial.new()
			glow_particles.process_material = _glow_material

func _setup_fire_gradient() -> void:
	# 火焰颜色渐变：白->黄->橙->红->透明
	fire_gradient = Gradient.new()
	fire_gradient.add_point(0.0, Color.WHITE)                    # 核心最亮
	fire_gradient.add_point(0.15, Color.YELLOW)                  # 黄色
	fire_gradient.add_point(0.4, Color.ORANGE)                   # 橙色
	fire_gradient.add_point(0.7, Color.RED)                      # 红色
	fire_gradient.add_point(1.0, Color(0.5, 0.0, 0.0, 0.0))     # 暗红淡出

func _configure_particles() -> void:
	_configure_main_fire()
	_configure_sparks()
	_configure_smoke()
	_configure_glow()

func _configure_main_fire() -> void:
	if not main_fire_particles or not _main_material:
		return

	# 主火焰配置
	main_fire_particles.one_shot = false
	main_fire_particles.amount = int(80 * fire_intensity)
	main_fire_particles.lifetime = 0.6
	main_fire_particles.explosiveness = 0.3
	main_fire_particles.randomness = 0.6

	# 发射形状 - 从点发射
	_main_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_main_material.emission_sphere_radius = 5.0 * particle_scale

	# 方向将在emit()中动态设置
	_main_material.direction = Vector3(1, 0, 0)
	_main_material.spread = 25.0  # 火焰扩散角度

	# 速度设置
	_main_material.initial_velocity_min = 400.0 * particle_scale
	_main_material.initial_velocity_max = 700.0 * particle_scale

	# 轻微向上的重力模拟热气上升
	_main_material.gravity = Vector3(0, -50, 0)

	# 阻尼
	_main_material.damping_min = 2.0
	_main_material.damping_max = 4.0

	# 缩放 - 从大到小
	_main_material.scale_min = 3.0 * particle_scale
	_main_material.scale_max = 8.0 * particle_scale

	# 颜色渐变
	_main_material.color_ramp = _create_gradient_texture(fire_gradient)

	# 随机性
	_main_material.lifetime_randomness = 0.3
	_main_material.angular_velocity_min = -180.0
	_main_material.angular_velocity_max = 180.0

func _configure_sparks() -> void:
	if not spark_particles or not _spark_material:
		return

	# 火花配置 - 小而亮的粒子
	spark_particles.one_shot = false
	spark_particles.amount = int(30 * fire_intensity)
	spark_particles.lifetime = 0.4
	spark_particles.explosiveness = 0.5
	spark_particles.randomness = 0.7

	# 火花颜色 - 亮黄到橙
	var spark_gradient = Gradient.new()
	spark_gradient.add_point(0.0, Color.WHITE)
	spark_gradient.add_point(0.3, Color.YELLOW)
	spark_gradient.add_point(1.0, Color(1.0, 0.5, 0.0, 0.0))
	_spark_material.color_ramp = _create_gradient_texture(spark_gradient)

	# 发射形状
	_spark_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_spark_material.emission_sphere_radius = 3.0 * particle_scale

	# 方向
	_spark_material.direction = Vector3(1, 0, 0)
	_spark_material.spread = 35.0

	# 速度 - 更快
	_spark_material.initial_velocity_min = 500.0 * particle_scale
	_spark_material.initial_velocity_max = 900.0 * particle_scale

	# 重力
	_spark_material.gravity = Vector3(0, 100, 0)

	# 缩放 - 小
	_spark_material.scale_min = 0.5 * particle_scale
	_spark_material.scale_max = 1.5 * particle_scale

	_spark_material.lifetime_randomness = 0.4

func _configure_smoke() -> void:
	if not smoke_particles or not _smoke_material:
		return

	# 烟雾配置 - 灰色上升的烟雾
	smoke_particles.one_shot = false
	smoke_particles.amount = int(25 * fire_intensity)
	smoke_particles.lifetime = 1.2
	smoke_particles.explosiveness = 0.2
	smoke_particles.randomness = 0.5

	# 烟雾颜色 - 灰色到透明
	var smoke_gradient = Gradient.new()
	smoke_gradient.add_point(0.0, Color(0.3, 0.3, 0.3, 0.6))
	smoke_gradient.add_point(0.5, Color(0.4, 0.4, 0.4, 0.4))
	smoke_gradient.add_point(1.0, Color(0.5, 0.5, 0.5, 0.0))
	_smoke_material.color_ramp = _create_gradient_texture(smoke_gradient)

	# 发射形状
	_smoke_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_smoke_material.emission_sphere_radius = 15.0 * particle_scale

	# 方向 - 向上
	_smoke_material.direction = Vector3(0, -1, 0)
	_smoke_material.spread = 45.0

	# 速度 - 慢
	_smoke_material.initial_velocity_min = 30.0 * particle_scale
	_smoke_material.initial_velocity_max = 80.0 * particle_scale

	# 重力 - 向上飘
	_smoke_material.gravity = Vector3(0, -30, 0)

	# 缩放 - 大
	_smoke_material.scale_min = 5.0 * particle_scale
	_smoke_material.scale_max = 12.0 * particle_scale

	_smoke_material.lifetime_randomness = 0.3

func _configure_glow() -> void:
	if not glow_particles or not _glow_material:
		return

	# 发光配置 - 核心亮光
	glow_particles.one_shot = false
	glow_particles.amount = int(15 * fire_intensity)
	glow_particles.lifetime = 0.3
	glow_particles.explosiveness = 0.4
	glow_particles.randomness = 0.3

	# 发光颜色 - 亮黄白
	var glow_gradient = Gradient.new()
	glow_gradient.add_point(0.0, Color(1.0, 1.0, 0.8, 0.9))
	glow_gradient.add_point(0.5, Color(1.0, 0.9, 0.5, 0.6))
	glow_gradient.add_point(1.0, Color(1.0, 0.6, 0.2, 0.0))
	_glow_material.color_ramp = _create_gradient_texture(glow_gradient)

	# 发射形状
	_glow_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	_glow_material.emission_sphere_radius = 8.0 * particle_scale

	# 方向
	_glow_material.direction = Vector3(1, 0, 0)
	_glow_material.spread = 20.0

	# 速度
	_glow_material.initial_velocity_min = 200.0 * particle_scale
	_glow_material.initial_velocity_max = 400.0 * particle_scale

	# 缩放 - 大而柔和
	_glow_material.scale_min = 6.0 * particle_scale
	_glow_material.scale_max = 12.0 * particle_scale

	_glow_material.lifetime_randomness = 0.2

func _create_gradient_texture(gradient: Gradient) -> GradientTexture1D:
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture

func _adjust_for_platform() -> void:
	# 根据平台调整粒子数量
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		particle_scale = 0.6
		fire_intensity = 0.7
		if main_fire_particles:
			main_fire_particles.amount = int(main_fire_particles.amount * 0.5)
		if spark_particles:
			spark_particles.amount = int(spark_particles.amount * 0.5)
		if smoke_particles:
			smoke_particles.amount = int(smoke_particles.amount * 0.5)
		if glow_particles:
			glow_particles.amount = int(glow_particles.amount * 0.5)

## 发射火焰
## @param start_position 火焰起始位置
## @param end_position 火焰目标位置（火焰将覆盖此区域）
func emit(start_position: Vector2, end_position: Vector2) -> void:
	_start_position = start_position
	_end_position = end_position

	# 计算火焰方向和距离
	_fire_direction = (_end_position - _start_position).normalized()
	_fire_distance = _end_position.distance_to(_start_position)

	# 设置特效位置
	position = _start_position

	# 更新粒子方向
	_update_particle_directions()

	# 开始发射
	_start_emitting()

func _update_particle_directions() -> void:
	var dir_3d = Vector3(_fire_direction.x, _fire_direction.y, 0)

	# 更新主火焰方向
	if _main_material:
		_main_material.direction = dir_3d

	# 更新火花方向
	if _spark_material:
		_spark_material.direction = dir_3d

	# 更新发光方向
	if _glow_material:
		_glow_material.direction = dir_3d

	# 根据距离调整速度
	var speed_multiplier = clamp(_fire_distance / 200.0, 0.5, 2.0)

	if _main_material:
		_main_material.initial_velocity_min = 400.0 * particle_scale * speed_multiplier
		_main_material.initial_velocity_max = 700.0 * particle_scale * speed_multiplier

	if _spark_material:
		_spark_material.initial_velocity_min = 500.0 * particle_scale * speed_multiplier
		_spark_material.initial_velocity_max = 900.0 * particle_scale * speed_multiplier

func _start_emitting() -> void:
	is_emitting = true

	# 启动所有粒子
	if main_fire_particles:
		main_fire_particles.emitting = true

	if spark_particles:
		spark_particles.emitting = true

	if smoke_particles:
		smoke_particles.emitting = true

	if glow_particles:
		glow_particles.emitting = true

	# 根据距离计算持续时间
	var emit_duration = clamp(_fire_distance / 300.0, 0.5, 1.5)

	# 延迟停止发射
	get_tree().create_timer(emit_duration).timeout.connect(_stop_emitting)

	# 调度清理
	if auto_cleanup:
		get_tree().create_timer(TOTAL_LIFETIME).timeout.connect(_cleanup)

func _stop_emitting() -> void:
	if main_fire_particles:
		main_fire_particles.emitting = false
	if spark_particles:
		spark_particles.emitting = false
	if smoke_particles:
		smoke_particles.emitting = false
	if glow_particles:
		glow_particles.emitting = false

func _cleanup() -> void:
	is_emitting = false
	_stop_all_particles()

func _stop_all_particles() -> void:
	if main_fire_particles:
		main_fire_particles.emitting = false
	if spark_particles:
		spark_particles.emitting = false
	if smoke_particles:
		smoke_particles.emitting = false
	if glow_particles:
		glow_particles.emitting = false

## 停止所有粒子
func stop() -> void:
	_cleanup()

## 设置火焰强度 (0.1 - 2.0)
func set_fire_intensity(intensity: float) -> void:
	fire_intensity = clamp(intensity, 0.1, 2.0)
	_configure_particles()

## 设置粒子缩放
func set_particle_scale(scale: float) -> void:
	particle_scale = scale
	_configure_particles()

## 获取火焰总生命周期
func get_total_lifetime() -> float:
	return TOTAL_LIFETIME
