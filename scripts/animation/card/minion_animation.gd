extends CardAnimation

class_name MinionAnimation

class AttackAnimation extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(attackMinion: Minion, behitMinion: Minion):
		self.attackMinion = attackMinion
		self.behitMinion = behitMinion
	func execute() -> void:
		print("执行攻击动画")
		var tween = attackMinion.create_tween()
	
		var original_pos = attackMinion.global_position
		var direction = (behitMinion.global_position - original_pos).normalized()
		var attack_offset = direction * 50

		# 蓄力后向前突进
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(attackMinion, "global_position", behitMinion.global_position - attack_offset, 1)

		# 短暂停顿
		tween.tween_callback(
			func():
				# 触发进击动画
				MinionAnimationCheck.attack(attackMinion, behitMinion)
				# 触发双方受伤动画
				attackMinion.take_damage(behitMinion.get_attack())
				behitMinion.take_damage(attackMinion.get_attack())
				attackMinion.add_animation(MinionAnimation.GetDamage.new(attackMinion))
				behitMinion.add_animation(MinionAnimation.GetDamage.new(behitMinion))
		).set_delay(0.3)
		
		# 加速回到原位
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(attackMinion, "global_position", attackMinion.get_followNode().global_position, 0.5)
		await tween.finished
		
class GetDamage extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行受击动画")
		# 记录原始状态
		var original_rotation = minion.rotation_degrees
		var original_scale = minion.scale

		# 创建 Tween
		var tween = minion.create_tween()
		tween.set_parallel(false)  # 顺序执行

		# 定义旋转偏移序列（相对于原始角度）
		var rotation_offsets = [-20 , +20, -10, 0]
		for offset in rotation_offsets:
			tween.tween_property(minion, "rotation_degrees", original_rotation + offset, 0.1)

		# 定义缩放序列（相对于原始缩放）
		var scale_multipliers = [0.9, 1.1, 1.0]
		for mult in scale_multipliers:
			tween.tween_property(minion, "scale", original_scale * mult, 0.1)
		await tween.finished
		
		# 检查是否死亡
		if minion.is_dead():
			minion.add_animation(MinionAnimation.DieAnimation.new(minion))
		
class DieAnimation extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行死亡动画")
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(minion, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
		await tween.finished
		MinionAnimationCheck.die(minion)
		minion.add_animation(MinionAnimation.RemoveAnimation.new(minion))
		if GameManager.is_fighting():
			if minion.is_belong_player():
				MinionAnimationCheck.check_revenge(GameManager.fightScene.playerDeskCardList, minion)
			else:
				MinionAnimationCheck.check_revenge(GameManager.fightScene.enemyDeskCardList, minion)
		
class RemoveAnimation extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行移除动画")
		if GameManager.is_fighting():
			GameManager.fightScene.delete_card(minion)
		if GameManager.is_shopping():
			GameManager.shopScene.delete_card(minion)

class BeTripleAnimation extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行被三连动画")
		minion.follow(false)
		var tween = minion.create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(minion, "scale", Vector2.ZERO, 1.5)
		tween.tween_property(minion, "modulate:a", 0.0, 1.5)
		tween.tween_property(minion, "global_position", Vector2.ZERO, 1.5)
		tween.tween_callback(
			func():
				minion.add_animation(MinionAnimation.RemoveAnimation.new(minion))
		)
		await tween.finished
		
class TripleAnimation extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行三连出现动画")
		minion.follow(false)
		minion.global_position = Vector2(0, 0)
		minion.scale = Vector2.ZERO
		minion.modulate.a = 0.0
		await minion.get_tree().create_timer(0.5).timeout
		var tween = minion.create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "scale", Vector2.ONE, 0.4)
		tween.tween_property(minion, "modulate:a", 1.0, 0.4)
		await tween.finished
		minion.follow(true)
	
class Golden extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行点金动画")
		minion.set_golden(true)
		minion.use_info()
	
class EffectCount extends MinionAnimation:
	var minion: Minion
	var currCount: int
	var maxCount: int
	func _init(minion: Minion, currCount: int, maxCount: int):
		self.minion = minion
		self.currCount = currCount
		self.maxCount = maxCount
	func execute() -> void:
		print("执行效果计数器变化动画")
		minion.update_effectCountLabel(currCount, maxCount)
		var mainLabel: Label = minion.effectCountLabel
		var effectLabel = mainLabel.duplicate(true)
		minion.add_child(effectLabel)
		effectLabel.global_position = mainLabel.global_position
		var tween = minion.create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)  # 缓动效果
		# 缩放动画：从1倍到目标倍率
		tween.tween_property(effectLabel, "scale", Vector2(4, 4), 1)
		tween.parallel().tween_property(effectLabel, "modulate:a", 0, 1)
		await tween.finished
		effectLabel.queue_free()

class DuoJinJianJiang extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行夺金健将动画")
		var original_scale = minion.scale  # 保存原始缩放
		var enlarged_scale = original_scale * 1.2  # 放大 1.5 倍
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", enlarged_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(minion, "modulate:a", 0.7, 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "modulate:a", 1.0, 0.1).set_ease(Tween.EASE_IN)
		await tween.finished
		
		# 开始数值计算
		minion.add_info(AddInfo.new(1, 1))

class BaiZhuanDutu extends MinionAnimation:
	func execute() -> void:
		print("执行白赚赌徒动画")
		# 开始数值计算
		GameManager.shopScene.add_coin(2)

class HaiShangZouSiFan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行海上走私贩动画")
		# 创建两张酒馆币，并放入手牌
		var info: MagicInfo = MagicData.get_magic_by_name("酒馆币")
		for i in range(2):
			if GameManager.is_fighting():
				if minion.is_belong_enemy():
					GameManager.fightScene.create_enemy_handCard(info, minion.global_position)
				else:
					GameManager.fightScene.create_player_handCard(info, minion.global_position)
			if GameManager.is_shopping():
				GameManager.shopScene.create_handCard(info, minion.global_position)

class LianTui extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发练腿加属性特效")
		var effect_sprite = Sprite2D.new()
		effect_sprite.texture = GameManager.animationAssets.LianTui_AddInfo_Texture
		effect_sprite.scale = Vector2(0.144, 0.139)
		effect_sprite.z_index = minion.get("z_index") + 1  # 显示在上方
		minion.add_child(effect_sprite)
		effect_sprite.position = Vector2(0,0)
		effect_sprite.modulate.a = 0.0
		
		var tween = minion.create_tween()
		# 快速淡入
		tween.tween_property(effect_sprite, "modulate:a", 1.0, 0.3)
		# 数值计算
		minion.add_info(AddInfo.new(1, 2))
		# 慢慢淡出
		tween.tween_property(effect_sprite, "modulate:a", 0.0, 1.5)
		await tween.finished
		if effect_sprite.is_inside_tree():
			effect_sprite.queue_free()

class GeLeiSiFaXiEr extends MinionAnimation:
	func execute() -> void:
		print("触发格蕾丝法希尔动画")
		# 创建抉择界面
		var choice_panel = ChoicePanel.new(GameManager.animationAssets.GeLeiSiFaXiEr_OptionList)
		var choice = await choice_panel.wait_for_choice()
		choice_panel.quit()
		if choice == 0:
			GameManager.playerAnimationQueue.add_animation(PlayerAnimation.GeLeiSiFaXiEr1.new())
		if choice == 1:
			GameManager.playerAnimationQueue.add_animation(PlayerAnimation.GeLeiSiFaXiEr1.new())

class KaiGuaHeGuan extends MinionAnimation:
	var minion: Minion
	var coinIncrease: int
	func _init(minion: Minion, coinIncrease):
		self.minion = minion
		self.coinIncrease = coinIncrease
	func execute() -> void:
		print("触发开挂荷官动画")
		# 创建抉择界面
		var original_scale = minion.scale  # 保存原始缩放
		var enlarged_scale = original_scale * 1.2  # 放大 1.5 倍
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", enlarged_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(minion, "modulate:a", 0.7, 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "modulate:a", 1.0, 0.1).set_ease(Tween.EASE_IN)
		await tween.finished
		
		minion.add_info(AddInfo.new(coinIncrease, coinIncrease))
	
class WanShaLieTou extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发顽砂猎头动画")
		# 获取两张掠夺者合约
		var info: MagicInfo = MagicData.get_magic_by_name("掠夺者合约")
		if GameManager.is_fighting():
			if minion.is_belong_enemy():
				GameManager.fightScene.create_enemy_handCard(info, minion.global_position)
			else:
				GameManager.fightScene.create_player_handCard(info, minion.global_position)
		if GameManager.is_shopping():
			GameManager.shopScene.create_handCard(info, minion.global_position)
			
class ShiKongChuanZhangGouWei extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发时空船长钩尾动画")
		var effect_sprite = Sprite2D.new()
		effect_sprite.texture = GameManager.animationAssets.GouWei_AddInfo_Texture
		effect_sprite.scale = Vector2(0.144, 0.139)
		effect_sprite.z_index = minion.get("z_index") + 1  # 显示在上方
		minion.add_child(effect_sprite)
		effect_sprite.position = Vector2(0, 0)
		effect_sprite.modulate.a = 0.0
		
		var tween = minion.create_tween()
		# 快速淡入
		tween.tween_property(effect_sprite, "modulate:a", 1.0, 0.3)
		# 数值计算
		minion.add_info(AddInfo.new(2, 0))
		# 慢慢淡出
		tween.tween_property(effect_sprite, "modulate:a", 0.0, 1.5)
		await tween.finished
		if effect_sprite.is_inside_tree():
			effect_sprite.queue_free()

class DaoJianShouCangJia extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(attackMinion: Minion, behitMinion: Minion):
		self.attackMinion = attackMinion
		self.behitMinion = behitMinion
	func execute() -> void:
		print("执行刀剑收藏家动画")
		if GameManager.is_shopping():
			return
		# 获取被攻击随从的相邻随从
		var neighborMinionList: Array[Minion] = []
		var neighborBoxList: Array[Control] = []
		# 先找到容器
		var container: HBoxContainer
		var cardList: Array[Card]
		if attackMinion.is_belong_enemy():
			container = GameManager.fightScene.playerDeskCardContainer
			cardList = GameManager.fightScene.playerDeskCardList
		else:
			container = GameManager.fightScene.enemyDeskCardContainer
			cardList = GameManager.fightScene.enemyDeskCardList
		# 获取被攻击随从在容器中的索引
		var index = container.get_children().find(behitMinion.get_followNode())
		# 收集相邻随从的box
		if index > 0:
			neighborBoxList.append(container.get_child(index - 1))
		if index < container.get_child_count() - 1:
			neighborBoxList.append(container.get_child(index + 1))
		# 根据box找到随从
		for box in neighborBoxList:
			for card in cardList:
				if box == card.get_followNode():
					neighborMinionList.append(card)
		for minion in neighborMinionList:
			minion.take_damage(attackMinion.get_attack())
			minion.add_animation(MinionAnimation.GetDamage.new(minion))
				
class HuoYaoYunShuGong extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行火药运输工加属性动画")
		var control: HuoYaoYunShuGong_Particles = GameManager.animationAssets.HuoYaoYunShuGong_Particles_Template.instantiate()
		minion.add_child(control)
		control.position = Vector2(0, 0)
		control.particles.emitting = true
		minion.add_info(AddInfo.new(4, 0))
		await control.particles.finished
		control.queue_free()

class ZhouFuHaiYuan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行咒缚海员动画")
		if GameManager.is_shopping():
			# 将一张随机法术置入手牌
			var magicInfo: MagicInfo = MagicData.get_random_magic_under_level(GameManager.shopLevel)
			GameManager.shopScene.create_handCard(magicInfo, minion.global_position)

class TouJinDaoDanGui extends MinionAnimation:
	func execute() -> void:
		print("执行偷金捣蛋鬼动画")
		if GameManager.is_shopping():
			# 统计金随从个数
			var count: int = 0
			for card in GameManager.shopScene.deskCardList:
				var minion: Minion = card
				if minion.is_golden():
					count += 1
			for i in range(count + 1):
				GameManager.shopScene.add_coin(2)

class JinYingDaoHangYuan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行精英导航员动画")
		if GameManager.is_shopping():
			## 先等待所有随从播放完动画
			#var waitList: Array[Card]
			#for card in GameManager.shopScene.deskCardList:
				#if card != minion:
					#waitList.append(card)
			#for card in GameManager.shopScene.handCardList:
				#waitList.append(card)
			#while GameManager.shopScene.is_list_idle(waitList):
				#await GameManager.get_tree().process_frame
			var cardList: Array[Card]
			for card in GameManager.shopScene.deskCardList:
				var minion: Minion = card
				if minion.is_golden():
					continue
				if card == self.minion:
					continue
				if minion.get_level() > 4:
					continue
				cardList.append(minion)
			var zhanhouChoose = ZhanhouChoose.new(minion, cardList)
			var choosed_minion: Minion = await zhanhouChoose.wait_for_choice()
			zhanhouChoose.quit()
			choosed_minion.add_animation(MinionAnimation.Golden.new(choosed_minion))
			
class DeLuSiTe extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行德鲁斯特加属性动画")
		var control: DeLuSiTe_Particles = GameManager.animationAssets.DeLuSiTe_Particles_Template.instantiate()
		minion.add_child(control)
		control.position = Vector2(0, 0)
		control.particles.emitting = true
		if minion.is_golden():
			minion.add_info(AddInfo.new(2, 2))
		minion.add_info(AddInfo.new(2, 2))
		await control.particles.finished
		control.queue_free()

class JianDuiShangJiang extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行舰队上将动画")
		if GameManager.is_shopping():
			var info: MinionInfo = MinionData.get_random_minion_in_race_under_level(GameManager.shopLevel, "海盗")
			GameManager.shopScene.create_handCard(info, minion.global_position)

class TuoNiShuangYa extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行托尼双牙动画")
		if GameManager.is_fighting():
			if minion.is_belong_player():
				var cardList: Array[Card] = GameManager.fightScene.playerDeskCardList
				var targetMinion: Minion = cardList.pick_random()
				# 寻找这张牌，并将它点金
				var minionInfo = GameManager.find_card(targetMinion.get_uniqueId())
				minionInfo.set_golden(true)
				targetMinion.add_animation(MinionAnimation.Golden.new(targetMinion))
				
