class_name PlayerAnimation

func execute():
	pass

class Choose extends PlayerAnimation:
	var optionList: Array
	func _init(optionList: Array) -> void:
		self.optionList = optionList
	func execute() -> void:
		var choice_panel = ChoicePanel.new(self.optionList)
		var choice = await choice_panel.wait_for_choice()
		choice_panel.quit()
		if choice == 0:
			GameManager.playerEffectList.add_effect(PlayerEffect.GeLeiSiFaXiEr1.new(2))
		if choice == 1:
			GameManager.playerEffectList.add_effect(PlayerEffect.GeLeiSiFaXiEr2.new(4))

class ZhanHouChoose extends PlayerAnimation:
	var cardList: Array[Card]
	signal choice_made(minion: Minion)
	func _init(cardList: Array) -> void:
		self.cardList = cardList
	func execute() -> void:
		var zhanhouChoose = ZhanhouChoose.new(cardList)
		var choosed_minion: Minion = await zhanhouChoose.wait_for_choice()
		zhanhouChoose.quit()
		choice_made.emit(choosed_minion)

class FightEnd extends PlayerAnimation:
	var cardList: Array[Card]
	var winPosition: Vector2
	var defeatPosition: Vector2
	signal finished()
	func _init(cardList: Array, winPosition: Vector2, defeatPosition: Vector2) -> void:
		self.cardList = cardList
		self.winPosition = winPosition
		self.defeatPosition = defeatPosition
	func execute() -> void:
		# 第一阶段：等级图标从小扩大动画
		var level_sprites: Array[Sprite2D] = []
		var sprite_levels: Array[int] = []  # 记录每个sprite当前的level
		var tweens: Array[Tween] = []

		for card in cardList:
			var level = card.get_level()
			if level < 1 or level > 6:
				continue

			var sprite = Sprite2D.new()
			sprite.texture = GameManager.levelSpriteTemplate[level]
			sprite.z_index = 1000  # 确保显示在最上层

			# 获取目标缩放值
			var target_scale = GameManager.levelSpriteScale[level] * 2

			# 设置初始缩放为0
			sprite.scale = Vector2(0, 0)
			card.add_child(sprite)
			sprite.position = Vector2(0, 0)
			level_sprites.append(sprite)
			sprite_levels.append(level)

			# 创建tween动画，从小扩大到目标scale，耗时2秒
			var tween = card.create_tween()
			tween.tween_property(sprite, "scale", target_scale, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			tweens.append(tween)

		# 等待所有扩大动画完成
		for tween in tweens:
			await tween.finished

		# 第二阶段：等级递减、星星飞出、winPosition星星计数动画
		var star_texture = GameManager.levelSpriteTemplate[1]
		var star_scale = GameManager.levelSpriteScale[1] * 2

		# 在winPosition处创建星星图标（从小扩大）
		var win_star = Sprite2D.new()
		win_star.texture = star_texture
		win_star.z_index = 100
		win_star.scale = Vector2(0, 0)
		GameManager.fightScene.add_child(win_star)
		win_star.global_position = winPosition

		var win_star_tween = GameManager.fightScene.create_tween()
		win_star_tween.tween_property(win_star, "scale", star_scale, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		# 计数标签
		var count_label = Label.new()
		count_label.text = "0"
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 70)
		count_label.add_theme_constant_override("outline_size", 25)
		count_label.z_index = 50  # 低于win_star，被遮挡
		GameManager.fightScene.add_child(count_label)
		count_label.global_position = winPosition + Vector2(-20, 30)

		var star_count = 0
		var total_stars = 0
		for level in sprite_levels:
			total_stars += level

		# 每隔0.5秒处理一次level减少
		var has_more_levels = true
		while has_more_levels:
			has_more_levels = false
			for i in range(level_sprites.size()):
				var sprite = level_sprites[i]
				var current_level = sprite_levels[i]

				if current_level > 0:
					has_more_levels = true

					# 创建飞出的星星
					var flying_star = Sprite2D.new()
					flying_star.texture = star_texture
					flying_star.z_index = 100
					flying_star.scale = star_scale  # 飞出的星星稍小

					# 获取sprite的全局位置
					var start_pos = sprite.global_position
					flying_star.global_position = start_pos
					GameManager.fightScene.add_child(flying_star)

					# 星星飞向winPosition的动画
					var fly_tween = GameManager.fightScene.create_tween()
					fly_tween.tween_property(flying_star, "global_position", winPosition, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
					# 同时添加旋转动画
					var rotate_tween = GameManager.fightScene.create_tween()
					rotate_tween.tween_property(flying_star, "rotation", flying_star.rotation + PI * 4, 0.4).set_ease(Tween.EASE_IN_OUT)
					fly_tween.tween_callback(func():
						flying_star.queue_free()
						count_label.text = str(int(count_label.text)+1)
						var new_tween = GameManager.fightScene.create_tween()
						new_tween.tween_property(win_star, "scale", win_star.scale + star_scale*0.5, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
						if int(count_label.text) == total_stars:
							# 所有星星到达，开始第三阶段动画
							await GameManager.get_tree().create_timer(0.5).timeout
							count_label.queue_free()
							# 清理level_sprites
							for s in level_sprites:
								s.queue_free()
							# 第三阶段：win_star飞向defeatPosition
							await _fly_to_defeat(win_star)
					)

					# 减少level并更新sprite
					sprite_levels[i] -= 1
					if sprite_levels[i] > 0:
						sprite.texture = GameManager.levelSpriteTemplate[sprite_levels[i]]
						sprite.scale = GameManager.levelSpriteScale[sprite_levels[i]] * 2
					else:
						# level为0，隐藏sprite
						sprite.visible = false

			# 等待0.5秒再进行下一轮
			if has_more_levels:
				await GameManager.get_tree().create_timer(0.5).timeout

		# 如果没有星星需要飞出，直接结束
		if total_stars == 0:
			await GameManager.get_tree().create_timer(0.5).timeout
			win_star.queue_free()
			count_label.queue_free()
			finished.emit()

	# 第三阶段：win_star飞向defeatPosition
	func _fly_to_defeat(win_star: Sprite2D) -> void:
		var start_pos = win_star.global_position
		var direction = (defeatPosition - start_pos).normalized()
		# 小幅后撤的位置（向后一点）
		var pull_back_pos = start_pos - direction * 100
		var original_scale = win_star.scale

		# 创建飞行动画序列
		var fly_tween = GameManager.fightScene.create_tween()

		# 第一步：小幅后撤
		fly_tween.tween_property(win_star, "global_position", pull_back_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

		# 停顿0.2秒
		fly_tween.tween_interval(0.2)

		# 第二步：快速飞向defeatPosition（越飞越快，速度骤然上升）
		fly_tween.tween_property(win_star, "global_position", defeatPosition, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

		# 同时添加旋转动画（全程旋转）
		var rotate_tween = GameManager.fightScene.create_tween()
		rotate_tween.tween_property(win_star, "rotation", win_star.rotation + PI * 8, 0.7).set_ease(Tween.EASE_IN)

		# 同时添加缩放动画（越飞越大）
		var scale_tween = GameManager.fightScene.create_tween()
		scale_tween.tween_property(win_star, "scale", original_scale * 3.0, 0.7).set_ease(Tween.EASE_IN)

		await fly_tween.finished

		# 到达defeatPosition后消失并创建爆炸粒子效果
		win_star.queue_free()
		_create_explosion_particles(defeatPosition)

		# 等待爆炸效果完成后结束动画
		await GameManager.get_tree().create_timer(1.5).timeout
		finished.emit()

	# 创建爆炸粒子效果
	func _create_explosion_particles(pos: Vector2) -> void:
		# ===== 主爆炸粒子（核心火焰） =====
		var explosion_particles = GPUParticles2D.new()
		explosion_particles.z_index = 1000
		explosion_particles.global_position = pos
		explosion_particles.one_shot = true
		explosion_particles.amount = 100
		explosion_particles.lifetime = 1.0
		explosion_particles.explosiveness = 1.0
		explosion_particles.randomness = 0.5

		var material = ParticleProcessMaterial.new()
		material.particle_flag_disable_z = true
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		material.emission_sphere_radius = 10.0
		material.direction = Vector3(0, 0, 0)
		material.spread = 180.0
		material.initial_velocity_min = 300.0
		material.initial_velocity_max = 600.0
		material.gravity = Vector3(0, 50, 0)
		material.scale_min = 5.0
		material.scale_max = 12.0
		material.damping_min = 3.0
		material.damping_max = 6.0

		var gradient = Gradient.new()
		gradient.add_point(0.0, Color.WHITE)
		gradient.add_point(0.15, Color.YELLOW)
		gradient.add_point(0.35, Color.ORANGE)
		gradient.add_point(0.6, Color.RED)
		gradient.add_point(1.0, Color(0.3, 0.0, 0.0, 0.0))
		var gradient_texture = GradientTexture1D.new()
		gradient_texture.gradient = gradient
		material.color_ramp = gradient_texture

		explosion_particles.process_material = material
		GameManager.fightScene.add_child(explosion_particles)
		explosion_particles.emitting = true

		# ===== 火花粒子（高速飞溅） =====
		var spark_particles = GPUParticles2D.new()
		spark_particles.z_index = 1000
		spark_particles.global_position = pos
		spark_particles.one_shot = true
		spark_particles.amount = 80
		spark_particles.lifetime = 0.6
		spark_particles.explosiveness = 1.0
		spark_particles.randomness = 0.8

		var spark_material = ParticleProcessMaterial.new()
		spark_material.particle_flag_disable_z = true
		spark_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		spark_material.emission_sphere_radius = 5.0
		spark_material.direction = Vector3(0, 0, 0)
		spark_material.spread = 180.0
		spark_material.initial_velocity_min = 500.0
		spark_material.initial_velocity_max = 900.0
		spark_material.gravity = Vector3(0, 200, 0)
		spark_material.scale_min = 1.5
		spark_material.scale_max = 4.0

		var spark_gradient = Gradient.new()
		spark_gradient.add_point(0.0, Color.WHITE)
		spark_gradient.add_point(0.2, Color.YELLOW)
		spark_gradient.add_point(0.5, Color.ORANGE)
		spark_gradient.add_point(1.0, Color(1.0, 0.3, 0.0, 0.0))
		var spark_gradient_texture = GradientTexture1D.new()
		spark_gradient_texture.gradient = spark_gradient
		spark_material.color_ramp = spark_gradient_texture

		spark_particles.process_material = spark_material
		GameManager.fightScene.add_child(spark_particles)
		spark_particles.emitting = true

		# ===== 核心闪光粒子（最亮） =====
		var glow_particles = GPUParticles2D.new()
		glow_particles.z_index = 1002
		glow_particles.global_position = pos
		glow_particles.one_shot = true
		glow_particles.amount = 40
		glow_particles.lifetime = 0.4
		glow_particles.explosiveness = 1.0

		var glow_material = ParticleProcessMaterial.new()
		glow_material.particle_flag_disable_z = true
		glow_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		glow_material.emission_sphere_radius = 15.0
		glow_material.direction = Vector3(0, 0, 0)
		glow_material.spread = 180.0
		glow_material.initial_velocity_min = 80.0
		glow_material.initial_velocity_max = 150.0
		glow_material.scale_min = 15.0
		glow_material.scale_max = 30.0

		var glow_gradient = Gradient.new()
		glow_gradient.add_point(0.0, Color(1.0, 1.0, 0.9, 1.0))
		glow_gradient.add_point(0.3, Color(1.0, 0.95, 0.7, 0.9))
		glow_gradient.add_point(0.6, Color(1.0, 0.7, 0.3, 0.5))
		glow_gradient.add_point(1.0, Color(1.0, 0.4, 0.1, 0.0))
		var glow_gradient_texture = GradientTexture1D.new()
		glow_gradient_texture.gradient = glow_gradient
		glow_material.color_ramp = glow_gradient_texture

		glow_particles.process_material = glow_material
		GameManager.fightScene.add_child(glow_particles)
		glow_particles.emitting = true

		# ===== 冲击波粒子（环形扩散） =====
		var shockwave_particles = GPUParticles2D.new()
		shockwave_particles.z_index = 1001
		shockwave_particles.global_position = pos
		shockwave_particles.one_shot = true
		shockwave_particles.amount = 60
		shockwave_particles.lifetime = 0.5
		shockwave_particles.explosiveness = 1.0

		var shockwave_material = ParticleProcessMaterial.new()
		shockwave_material.particle_flag_disable_z = true
		shockwave_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		shockwave_material.emission_sphere_radius = 8.0
		shockwave_material.direction = Vector3(0, 0, 0)
		shockwave_material.spread = 180.0
		shockwave_material.initial_velocity_min = 400.0
		shockwave_material.initial_velocity_max = 500.0
		shockwave_material.gravity = Vector3(0, 0, 0)
		shockwave_material.scale_min = 3.0
		shockwave_material.scale_max = 6.0
		shockwave_material.damping_min = 8.0
		shockwave_material.damping_max = 12.0

		var shockwave_gradient = Gradient.new()
		shockwave_gradient.add_point(0.0, Color(1.0, 0.9, 0.5, 0.9))
		shockwave_gradient.add_point(0.3, Color(1.0, 0.6, 0.2, 0.6))
		shockwave_gradient.add_point(1.0, Color(0.8, 0.3, 0.1, 0.0))
		var shockwave_gradient_texture = GradientTexture1D.new()
		shockwave_gradient_texture.gradient = shockwave_gradient
		shockwave_material.color_ramp = shockwave_gradient_texture

		shockwave_particles.process_material = shockwave_material
		GameManager.fightScene.add_child(shockwave_particles)
		shockwave_particles.emitting = true

		# ===== 碎片粒子（四散飞射） =====
		var debris_particles = GPUParticles2D.new()
		debris_particles.z_index = 1000
		debris_particles.global_position = pos
		debris_particles.one_shot = true
		debris_particles.amount = 40
		debris_particles.lifetime = 0.8
		debris_particles.explosiveness = 1.0
		debris_particles.randomness = 0.9

		var debris_material = ParticleProcessMaterial.new()
		debris_material.particle_flag_disable_z = true
		debris_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		debris_material.emission_sphere_radius = 3.0
		debris_material.direction = Vector3(0, 0, 0)
		debris_material.spread = 180.0
		debris_material.initial_velocity_min = 350.0
		debris_material.initial_velocity_max = 700.0
		debris_material.gravity = Vector3(0, 300, 0)
		debris_material.scale_min = 2.0
		debris_material.scale_max = 5.0
		debris_material.angular_velocity_min = -720.0
		debris_material.angular_velocity_max = 720.0

		var debris_gradient = Gradient.new()
		debris_gradient.add_point(0.0, Color(1.0, 0.8, 0.3, 1.0))
		debris_gradient.add_point(0.4, Color(1.0, 0.5, 0.1, 0.7))
		debris_gradient.add_point(1.0, Color(0.5, 0.2, 0.0, 0.0))
		var debris_gradient_texture = GradientTexture1D.new()
		debris_gradient_texture.gradient = debris_gradient
		debris_material.color_ramp = debris_gradient_texture

		debris_particles.process_material = debris_material
		GameManager.fightScene.add_child(debris_particles)
		debris_particles.emitting = true

		# 延迟清理粒子节点
		await GameManager.get_tree().create_timer(2.5).timeout
		explosion_particles.queue_free()
		spark_particles.queue_free()
		glow_particles.queue_free()
		shockwave_particles.queue_free()
		debris_particles.queue_free()
