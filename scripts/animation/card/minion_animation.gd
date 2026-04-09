extends CardAnimation

class_name MinionAnimation

class AttackStartAnimation extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(attackMinion: Minion, behitMinion: Minion):
		self.attackMinion = attackMinion
		self.behitMinion = behitMinion
	func execute() -> void:
		print("执行攻击前后撤动画")
		attackMinion.follow(false)
		var tween = attackMinion.create_tween()
		var backOffset = (behitMinion.global_position - attackMinion.global_position).normalized() * 40
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(attackMinion, "global_position", attackMinion.global_position - backOffset, 0.5)
		await tween.finished
		# 触发进击动画
		MinionAnimationCheck.attack_before(attackMinion, behitMinion)
		# 触发攻击动画
		attackMinion.add_animation(MinionAnimation.AttackIngAnimation.new(attackMinion, behitMinion))

class AttackIngAnimation extends MinionAnimation:
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
		tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(attackMinion, "global_position", behitMinion.global_position - attack_offset,0.2)

		# 短暂停顿
		tween.tween_callback(
			func():
				# 触发攻击时动画判断
				MinionAnimationCheck.attack_ing(attackMinion, behitMinion)
				# 添加攻击返回动画
				attackMinion.add_animation(MinionAnimation.AttackEndAnimation.new(attackMinion, behitMinion))
		)
		await tween.finished
		
class AttackEndAnimation extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(attackMinion: Minion, behitMinion: Minion):
		self.attackMinion = attackMinion
		self.behitMinion = behitMinion
	func execute() -> void:
		print("执行攻击后返回动画")
		var tween = attackMinion.create_tween()
		# 加速回到原位
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(attackMinion, "global_position", attackMinion.get_followNode().global_position, 0.5)
		await tween.finished
		
		# 触发双方受伤动画
		attackMinion.take_damage(behitMinion.get_attack())
		behitMinion.take_damage(attackMinion.get_attack())
		
		# 触发攻击后判定逻辑
		MinionAnimationCheck.attack_after(attackMinion, behitMinion)
		
		# 开始跟随
		attackMinion.follow(true)
		
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
		#if minion.is_dead():
			#minion.add_animation(MinionAnimation.DieAnimation.new(minion))
		
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
		if GameManager.is_fighting():
			GameManager.fightScene.remove_card(minion)
		if GameManager.is_shopping():
			GameManager.shopScene.remove_card(minion)
		MinionAnimationCheck.die(minion) # 出发死亡相关动画
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
		# 先确保所有子随从动画已经执行完
		if minion.is_ronghe():
			while true:
				var idle: bool = true
				for baseMinion in minion.minionFather.get_children():
					if not baseMinion.is_idle():
						idle = false
						break
				if idle:
					break
				await GameManager.get_tree().process_frame
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
		minion.update_effectCountLabel()
		var mainLabel: Label = minion.effectCountLabel
		var effectLabel = mainLabel.duplicate(true)
		minion.add_child(effectLabel)
		effectLabel.global_position = mainLabel.global_position
		var tween = minion.create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)  # 缓动效果
		# 缩放动画：从1倍到目标倍率
		tween.tween_property(effectLabel, "scale", Vector2(4, 4), 0.4)
		tween.parallel().tween_property(effectLabel, "modulate:a", 0, 0.4)
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
		tween.tween_property(minion, "modulate:a", 0.7, 0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN)
		await tween.finished
		
		# 开始数值计算
		minion.add_stats(Stats.new(1, 1))

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
		var info: MagicInfo = MagicData.get_magic_by_name(GameManager.allMagicInfo, "酒馆币")
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
		minion.animationFather.add_child(effect_sprite)
		effect_sprite.position = Vector2(0,0)
		effect_sprite.modulate.a = 0.0
		
		var tween = minion.create_tween()
		# 快速淡入
		tween.tween_property(effect_sprite, "modulate:a", 1.0, 0.3)
		# 数值计算
		minion.add_stats(Stats.new(1, 2))
		# 慢慢淡出
		tween.tween_property(effect_sprite, "modulate:a", 0.0, 1.5)
		await tween.finished
		if effect_sprite.is_inside_tree():
			effect_sprite.queue_free()

class GeLeiSiFaXiEr extends MinionAnimation:
	func execute() -> void:
		print("触发格蕾丝法希尔动画")
		# 创建抉择界面
		GameManager.playerAnimationQueue.add_animation(PlayerAnimation.Choose.new(GameManager.animationAssets.GeLeiSiFaXiEr_OptionList))
		
class KaiGuaHeGuan extends MinionAnimation:
	var minion: Minion
	var coinIncrease: int
	func _init(minion: Minion, coinIncrease):
		self.minion = minion
		self.coinIncrease = coinIncrease
	func execute() -> void:
		print("触发开挂荷官动画")
		var original_scale = minion.scale  # 保存原始缩放
		var enlarged_scale = original_scale * 1.2  # 放大 1.5 倍
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", enlarged_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(minion, "modulate:a", 0.7, 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(minion, "modulate:a", 1.0, 0.1).set_ease(Tween.EASE_IN)
		await tween.finished
		
		minion.add_stats(Stats.new(coinIncrease, coinIncrease))
	
class WanShaLieTou extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发顽砂猎头动画")
		# 获取两张掠夺者合约
		var info: MagicInfo = MagicData.get_magic_by_name(GameManager.allMagicInfo, "掠夺者合约")
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
		minion.animationFather.add_child(effect_sprite)
		effect_sprite.position = Vector2(0, 0)
		effect_sprite.modulate.a = 0.0
		
		var tween = minion.create_tween()
		# 快速淡入
		tween.tween_property(effect_sprite, "modulate:a", 1.0, 0.3)
		# 数值计算
		minion.add_stats(Stats.new(2, 0))
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
		# 先找到容器和卡牌列表
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
			
class HuoYaoYunShuGong extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行火药运输工加属性动画")
		var control: HuoYaoYunShuGong_Particles = GameManager.animationAssets.HuoYaoYunShuGong_Particles_Template.instantiate()
		minion.animationFather.add_child(control)
		control.position = Vector2(0, 0)
		control.particles.emitting = true
		minion.add_stats(Stats.new(4, 0))
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
			var magicInfo: MagicInfo = MagicData.get_random_magic_under_level(GameManager.shopMagicInfo, GameManager.shopLevel)
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
			var cardList: Array[Card]
			for card in GameManager.shopScene.deskCardList:
				var targetMinion: Minion = card
				if targetMinion.is_golden():
					continue
				if targetMinion.is_equal(minion):
					continue
				if targetMinion.get_level() > 4:
					continue
				cardList.append(targetMinion)
			if cardList.is_empty():
				return 
			var chooseAnimation: PlayerAnimation = PlayerAnimation.zhanHouChoose.new(cardList)
			GameManager.add_playerAnimation(chooseAnimation)
			var choosedMinion: Minion = await await chooseAnimation.choice_made
			if not is_instance_valid(choosedMinion):
				return
			choosedMinion.add_animation(MinionAnimation.Golden.new(choosedMinion))
			
class DeLuSiTe extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行德鲁斯特加属性动画")
		var control: DeLuSiTe_Particles = GameManager.animationAssets.DeLuSiTe_Particles_Template.instantiate()
		minion.animationFather.add_child(control)
		control.position = Vector2(0, 0)
		control.particles.emitting = true
		if minion.is_golden():
			minion.add_stats(Stats.new(2, 2))
		minion.add_stats(Stats.new(2, 2))
		await control.particles.finished
		control.queue_free()

class JianDuiShangJiang extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行舰队上将动画")
		if GameManager.is_shopping():
			var info: MinionInfo = MinionData.get_random_minion_in_race_under_level(GameManager.shopMinionInfo, GameManager.shopLevel, "海盗")
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
				
class JinBiZhaPianFan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行金币诈骗犯动画")
		if GameManager.is_shopping():
			minion.add_boostCount(1)
			GameManager.coinLimit += 1
			GameManager.shopScene.display_coin()
			
class LuoShuLongGuFan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行洛书龙骨帆动画")
		if GameManager.is_shopping():
			# 随机获取一张海盗牌，并加入手牌
			var info: MinionInfo = MinionData.get_random_minion_in_race_under_level(GameManager.shopMinionInfo, GameManager.shopLevel, "海盗")
			GameManager.shopScene.create_handCard(info, minion.global_position)
			
class ShiYuanChuanZhang extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行时渊船长克罗诺斯动画")
		if GameManager.is_shopping():
			GameManager.shopScene.add_coin(1)
			
class HuangJinKuangChao extends MinionAnimation:
	var minion: Minion
	var minionList: Array[Minion]
	func _init(minion: Minion, minionList: Array[Minion]):
		self.minion = minion
		self.minionList = minionList
	func execute() -> void:
		print("执行黄金狂潮齐射协议动画")
		if GameManager.is_shopping():
			var particlesList: Array[Control]
			for targetMinion in minionList:
				if is_instance_valid(targetMinion): # 确保执行动画时随从还存在
					var particles: HuangJinKuangChao_Particles = GameManager.animationAssets.HuangJinKuangChao_Particles_Template.instantiate()
					particles.startPosition = minion.clickSprite.global_position
					particles.explodePosition = targetMinion.global_position
					particles.emitting = true
					GameManager.shopScene.cardFatherNode.add_child(particles)
					particlesList.append(particles)
			await GameManager.get_tree().create_timer(0.5).timeout
			# 爆炸动画开始前，开始增加数值
			for targetMinion in minionList:
				if is_instance_valid(targetMinion):
					targetMinion.add_stats(Stats.new(10+minion.get_boostCount()*5, 10+minion.get_boostCount()*5))
			minion.add_boostCount(1)
			await GameManager.get_tree().create_timer(1).timeout
			for particles in particlesList:
				particles.queue_free()
			
	
class HaoQiDeLueDuoZhe extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行好奇的掠夺者动画")
		if GameManager.is_shopping():
			var info: MinionInfo = MinionData.get_random_minion_under_level(GameManager.shopMinionInfo, GameManager.shopLevel)
			info.set_golden(true)
			GameManager.shopScene.create_handCard(info, minion.global_position)
			
class BaoLieJuFeng extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("执行爆裂飓风动画")
		var original_scale = minion.scale  # 保存原始缩放
		var enlarged_scale = original_scale * 1.2  # 放大 1.5 倍
		var tween1 = minion.create_tween()
		tween1.tween_property(minion, "scale", enlarged_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween1.tween_property(minion, "modulate:a", 0.7, 0.2).set_ease(Tween.EASE_OUT)
		await tween1.finished
		
		# 开始数值计算
		var stats: Stats = AnimationAssets.YuanSuAddInfo.get_stats(AnimationAssets.YuanSuAddInfo.baoliejufeng)
		minion.add_stats(stats)
		var minionInfo:MinionInfo = GameManager.find_card(minion.get_uniqueId())
		minionInfo.add_stats(stats)
		
		var tween2 = minion.create_tween()
		tween2.tween_property(minion, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		tween2.tween_property(minion, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN)
		await tween2.finished
		
class ShangFanYuanSu extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发商贩元素动画：获取一张 3/3 的随机元素牌")
		if GameManager.is_shopping():
			var randomElementInfo: MinionInfo = MinionData.get_random_minion_in_race_under_level(GameManager.shopMinionInfo, GameManager.shopLevel, "元素" )
			if randomElementInfo == null:
				print("警告：当前等级没有可用的元素牌")
				return
			randomElementInfo.attack = 3
			randomElementInfo.health = 3
			GameManager.shopScene.create_handCard(randomElementInfo, minion.global_position)

class FuRaoDeJiYan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发富饶的基岩动画：回合结束获取一张随机元素牌")
		if GameManager.is_shopping():
			var randomElementInfo: MinionInfo = MinionData.get_random_minion_in_race_under_level(GameManager.shopMinionInfo, GameManager.shopLevel, "元素" )
			if randomElementInfo == null:
				print("警告：当前等级没有可用的元素牌")
				return
			GameManager.shopScene.create_handCard(randomElementInfo, minion.global_position)

class YeHuoYuanSu extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(attackMinion: Minion, behitMinion: Minion):
		self.attackMinion = attackMinion
		self.behitMinion = behitMinion
	func execute() -> void:
		print("触发野火元素动画")
		if GameManager.is_fighting():
			# 获取被攻击随从的相邻随从
			var neighborMinionList: Array[Minion] = []
			var neighborBoxList: Array[Control] = []
			# 先找到容器和卡牌列表
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
			if neighborMinionList.is_empty():
				return
			var neiborMinion: Minion = neighborMinionList.pick_random()
			neiborMinion.take_damage(neiborMinion.get_health())
			
class PaiDuiYuanSu extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发派对元素动画")
		if GameManager.is_shopping():
			var control : PaiDuiYuanSu_Particles = GameManager.animationAssets.PaiDuiYuanSu_Particles_Template.instantiate()
			minion.animationFather.add_child(control)
			control.position = Vector2(0, 0)
			control.emit()
			var stats: Stats = AnimationAssets.YuanSuAddInfo.get_stats(AnimationAssets.YuanSuAddInfo.paiduiyuansu)
			minion.add_stats(stats)
			await minion.get_tree().create_timer(control.get_total_lifetime()).timeout
			control.queue_free()
			
class ZhaoZeYouDangZhe extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发沼泽游荡者动画")
		if GameManager.is_shopping():
			# 触发选择场上的随从动画
			var cardList: Array[Card]
			for card in GameManager.shopScene.deskCardList:
				var targetMinion: Minion = card
				if targetMinion.is_equal(minion):
					continue
				cardList.append(targetMinion)
			if cardList.is_empty():
				return 
			var chooseAnimation: PlayerAnimation = PlayerAnimation.zhanHouChoose.new(cardList)
			GameManager.add_playerAnimation(chooseAnimation)
			var choosedMinion : Minion = await chooseAnimation.choice_made
			if not is_instance_valid(choosedMinion):
				return
			choosedMinion.close_click()
			choosedMinion.close_clock()
			GameManager.shopScene.remove_deskCard(choosedMinion)
			GameManager.shopScene.add_handCard(choosedMinion)
			choosedMinion.add_stats(Stats.new(3, 3))
		
class KuangFangDeFaLi extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发狂放的法力涌流动画")
		if GameManager.is_shopping():
			var stats: Stats = AnimationAssets.YuanSuAddInfo.get_stats(AnimationAssets.YuanSuAddInfo.kuangfangdefali)
			minion.add_stats(stats)

class TianDianDaLu extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发甜点大陆动画")
		if GameManager.is_shopping():
			GameManager.shopScene.create_handCard(MinionData.get_minion_by_name(GameManager.allMinionInfo, "甜蜜元素"), minion.global_position)
		elif GameManager.is_fighting():
			if minion.is_belong_enemy():
				GameManager.fightScene.create_enemy_handCard(MinionData.get_minion_by_name(GameManager.allMinionInfo, "甜蜜元素"), minion.global_position)
			else:
				GameManager.fightScene.create_player_handCard(MinionData.get_minion_by_name(GameManager.allMinionInfo, "甜蜜元素"), minion.global_position)

class YiLiuRongYan extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发溢流熔岩动画")
		var useCardCount_YuanSu: PlayerEffect = PlayerEffectCheck.find_effect(PlayerEffect.UseCardCount_YuanSu.new())
		var value = useCardCount_YuanSu.get_value()
		minion.add_stats(AnimationAssets.YuanSuAddInfo.get_stats(Stats.new(value, value)))

class SuiLieJuYanMaiShaDun extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发碎裂巨岩迈沙顿动画")
		if not GameManager.is_shopping():
			return
		# 触发选择场上的随从动画
		var cardList: Array[Card]
		for card in GameManager.shopScene.deskCardList:
			var targetMinion: Minion = card
			if targetMinion.is_equal(minion):
				continue
			if targetMinion.get_race().contains("元素"):
				cardList.append(targetMinion)
		if cardList.is_empty():
			return 
		var chooseAnimation: PlayerAnimation = PlayerAnimation.zhanHouChoose.new(cardList)
		GameManager.add_playerAnimation(chooseAnimation)
		var choosedMinion : Minion = await chooseAnimation.choice_made
		if not is_instance_valid(choosedMinion):
			return
		# 裂解成两半
		var choosedMinionStats: Stats = choosedMinion.get_stats()
		var crackedStats: Stats = Stats.new(max(choosedMinionStats.get_attack()/2, 1), max(choosedMinionStats.get_health()/2, 1))
		var crackedInfo1: MinionInfo = choosedMinion.get_info().create()
		var crackedInfo2: MinionInfo = choosedMinion.get_info().create()
		crackedInfo1.set_stats(crackedStats)
		crackedInfo2.set_stats(crackedStats)
		var crackedPostion1: Vector2 = choosedMinion.global_position + Vector2(1, 0)
		var crackedPostion2: Vector2 = choosedMinion.global_position + Vector2(2, 0)
		GameManager.shopScene.delete_card(choosedMinion)
		GameManager.shopScene.create_deskCard(crackedInfo1, crackedPostion1)
		GameManager.shopScene.create_deskCard(crackedInfo2, crackedPostion2)
		
class YongRanHuoFeng extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发永燃火凤动画")
		if not GameManager.is_fighting():
			return
		if minion.get_effectCount() == 0:
			return
		# 尝试召唤
		if randi_range(1, 10) <= minion.get_effectCount():
			# 召唤并获取
			var newDeskMinion: Minion
			var newHandMinion: Minion
			var originDeskInfo: MinionInfo = MinionData.get_minion_by_id(GameManager.shopMinionInfo, minion.get_id())
			var originHandInfo: MinionInfo = MinionData.get_minion_by_id(GameManager.shopMinionInfo, minion.get_id())
			if minion.is_belong_enemy():
				newDeskMinion = GameManager.fightScene.create_enemy_deskCard(originDeskInfo, minion.global_position)
				newHandMinion = GameManager.fightScene.create_enemy_handCard(originHandInfo, minion.global_position)
			else:
				newDeskMinion = GameManager.fightScene.create_player_deskCard(originDeskInfo, minion.global_position)
				newHandMinion = GameManager.fightScene.create_player_handCard(originHandInfo, minion.global_position)
			# 修改效果计数器
			if is_instance_valid(newDeskMinion):
				newDeskMinion.create_effectCount(minion.get_effectCount()-1, 10, func(paramSelf):
					pass)
			if is_instance_valid(newHandMinion):
				newHandMinion.create_effectCount(10, 10, func(paramSelf):
					pass)
		
class WenHeDeDengShen extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发温和的灯神动画")
		if not GameManager.is_shopping():
			return
		# 先选择一个随从
		var cardList: Array[Card] = []
		for card in GameManager.shopScene.deskCardList:
			var targetMinion: Minion = card
			if targetMinion.is_equal(minion):
				continue
			if targetMinion.get_race().contains("元素"):
				cardList.append(targetMinion)
		if cardList.size() <= 1: # 不够两个随从
			return 
		var chooseAnimation1: PlayerAnimation = PlayerAnimation.zhanHouChoose.new(cardList)
		GameManager.add_playerAnimation(chooseAnimation1)
		var choosedMinion1 : Minion = chooseAnimation1.choice_made
		if not is_instance_valid(choosedMinion1):
			return
		# 再选择第二个随从
		cardList = []
		for card in GameManager.shopScene.deskCardList:
			var targetMinion: Minion = card
			if targetMinion.is_equal(minion) or targetMinion.is_equal(choosedMinion1):
				continue
			if targetMinion.get_race().contains("元素"):
				if targetMinion.get_race() != choosedMinion1.get_race():
					cardList.append(targetMinion)
		if cardList.is_empty():
			return
		var chooseAnimation2: PlayerAnimation = PlayerAnimation.zhanHouChoose.new(cardList)
		GameManager.add_playerAnimation(chooseAnimation2)
		var choosedMinion2 : Minion = chooseAnimation2.choice_made
		if not is_instance_valid(choosedMinion2):
			return
		# 融合两个元素
		await Minion.ronghe(choosedMinion1, choosedMinion2)
		GameManager.shopScene.delete_card(choosedMinion1)
		GameManager.shopScene.delete_card(choosedMinion2)
		
class ZengQiangDeGuangYao extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发增强的光耀之子动画")
		GameManager.playerEffectList.add_effect(PlayerEffect.YuanSuStatsBuff.new(Stats.new(1, 1)))

class YiXinDiAoSi extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func execute() -> void:
		print("触发伊辛迪奥斯动画")
		# 随机选择两个敌方随从 
		if GameManager.is_fighting():
			var deskMinionList: Array[Card]
			if minion.is_belong_player():
				deskMinionList = GameManager.fightScene.enemyDeskCardList.duplicate(true)
			else:
				deskMinionList = GameManager.fightScene.playerDeskCardList.duplicate(true)
			deskMinionList.shuffle()
			var minionList: Array[Card]
			if deskMinionList.size() > 2:
				minionList = [deskMinionList[0], deskMinionList[1]]
			else:
				minionList = deskMinionList
			for minionInList: Minion in minionList:
				minionInList.take_damage(minion.get_attack())

class BuMieCanHe extends MinionAnimation:
	var minion: Minion
	var rongheInfo: MinionInfo
	var otherMinion: Minion
	func _init(rongheInfo: MinionInfo, minion: Minion, otherMinion: Minion):
		self.minion = minion
		self.rongheInfo = rongheInfo
		self.otherMinion = otherMinion
	func execute() -> void:
		print("触发不灭残荷动画")
		rongheInfo.add_stats(Stats.double(Stats.add_stats(minion.get_stats(), otherMinion.get_stats())))
