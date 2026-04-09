class_name MinionAnimationCheck

static func check_coin_increase(cardList: Array[Card], coinIncrease: int) -> void:
	for card in cardList:
		if card.is_minion():
			coin_increase(card, coinIncrease)
		
static func check_coin_decrease(cardList: Array[Card], coinDecrease: int) -> void:
	for card in cardList:
		if card.is_minion():
			coin_decrease(card, coinDecrease)

static func check_buy(cardList: Array[Card], buyCard: Card) -> void:
	for card in cardList:
		if card.is_minion():
			buy(card, buyCard)
		
static func check_sell(cardList: Array[Card]) -> void:
	for card in cardList:
		if card.is_minion():
			sell(card)
		
static func check_revenge(cardList: Array[Card], dieMinion: Minion) -> void:
	for card in cardList:
		if card.is_minion():
			var minion: Minion = card
			if minion.get_uniqueId() == dieMinion.get_uniqueId():
				continue
			revenge(minion)
		
static func check_add_hand(cardList: Array[Card], addCard: Card) -> void:
	for card in cardList:
		if card.is_minion():
			add_hand(card, addCard)
		
static func check_use_magic(cardList: Array[Card]) -> void:
	for card in cardList:
		if card.is_minion():
			use_magic(card)
			
static func check_use_minion(cardList: Array[Card], usedMinion: Card) -> void:
	for card in cardList:
		if card.is_minion():
			use_minion(card, usedMinion)
		
static func check_round_start(cardList: Array[Card]) -> void:
	for card in cardList:
		if card.is_minion():
			round_start(card)
		
static func check_round_end(cardList: Array[Card]) -> void:
	for card in cardList:
		if card.is_minion():
			round_end(card)

# 金币数量增加
static func coin_increase(minion: Minion, coinIncrease: int) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			coin_increase(baseMinion, coinIncrease)
	match minion.get_cardName():
		"夺金健将":
			minion.add_animation(MinionAnimation.DuoJinJianJiang.new(minion))
		"开挂荷官":
			minion.add_animation(MinionAnimation.KaiGuaHeGuan.new(minion, coinIncrease))

# 金币数量减少
static func coin_decrease(minion: Minion, coinDecrease: int) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			coin_decrease(baseMinion, coinDecrease)
	match minion.get_cardName():
		"火药运输工":
			minion.add_effectCount(coinDecrease)
		"舰队上将":
			minion.add_effectCount(coinDecrease)

# 购买
static func buy(minion: Minion, buyCard: Card) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			buy(baseMinion, buyCard)
	match minion.get_cardName():
		"咒缚海员":
			if buyCard.is_minion():
				minion.add_effectCount(1)

# 出售
static func sell(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			sell(baseMinion)
	match minion.get_cardName():
		"白赚赌徒":
			minion.add_animation(MinionAnimation.BaiZhuanDutu.new())
		"商贩元素":
			minion.add_animation(MinionAnimation.ShangFanYuanSu.new(minion))

# 亡语
static func die(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			die(baseMinion)
	match minion.get_cardName():
		"海上走私贩":
			minion.add_animation(MinionAnimation.HaiShangZouSiFan.new(minion))
		"永燃火凤":
			minion.add_animation(MinionAnimation.YongRanHuoFeng.new(minion))

# 复仇
static func revenge(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			revenge(baseMinion)
	match minion.get_cardName():
		"托尼双牙":
			minion.add_effectCount(1)
		"伊辛迪奥斯":
			minion.add_effectCount(1)
			
# 置入手牌
static func add_hand(minion: Minion, addCard: Card) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			add_hand(baseMinion, addCard)
	match minion.get_cardName():
		"练腿":
			# 随机选择场上另两个友方随从
			if GameManager.is_shopping():
				var deskMinionList = GameManager.shopScene.deskCardList.duplicate(true)
				deskMinionList.shuffle()
				deskMinionList.erase(minion)
				var minionList: Array[Card]
				if deskMinionList.size() > 2:
					minionList = [deskMinionList[0], deskMinionList[1]]
				else:
					minionList = deskMinionList
				for minionInList in minionList:
					minionInList.add_animation(MinionAnimation.LianTui.new(minionInList))
		"德鲁斯特":
			if addCard.is_minion():
				var addMinion: Minion = addCard
				if addMinion.get_race().contains("海盗"):
					if GameManager.is_shopping():
						for card in GameManager.shopScene.deskCardList:
							card.add_animation(MinionAnimation.DeLuSiTe.new(card))
		"金币诈骗犯":
			if addCard.is_minion():
				var addMinion: Minion = addCard
				if addMinion.get_race().contains("海盗"):
					if GameManager.is_shopping():
						minion.add_effectCount(1)
		"大厨诺米":
			if addCard.is_minion():
				var addMinion: Minion = addCard
				if addMinion.get_race().contains("元素"):
					minion.add_effectCount(1)
		
# 上场（战吼）
static func use(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			use(baseMinion)
	match minion.get_cardName():
		"格蕾丝法希尔":
			minion.add_animation(MinionAnimation.GeLeiSiFaXiEr.new())
		"顽砂猎头":
			minion.add_animation(MinionAnimation.WanShaLieTou.new(minion))
		"火药运输工":
			minion.create_effectCount(0, 5, func(paramSelf: Minion):
				if GameManager.is_shopping():
					for card in GameManager.shopScene.deskCardList:
						card.add_animation(MinionAnimation.HuoYaoYunShuGong.new(card))
						)
		"咒缚海员":
			minion.create_effectCount(0, 3, func(paramSelf: Minion):
				paramSelf.add_animation(MinionAnimation.ZhouFuHaiYuan.new(paramSelf))
				)
		"精英导航员":
			minion.add_animation(MinionAnimation.JinYingDaoHangYuan.new(minion))
		"舰队上将":
			minion.create_effectCount(0, 9, func(paramSelf: Minion):
				paramSelf.add_animation(MinionAnimation.JianDuiShangJiang.new(paramSelf))
				)
		"托尼双牙":
			minion.create_effectCount(0, 1, func(paramSelf: Minion):
				paramSelf.add_animation(MinionAnimation.TuoNiShuangYa.new(paramSelf))
				)
		"金币诈骗犯":
			minion.create_boostCount(0)
			minion.add_animation(MinionAnimation.JinBiZhaPianFan.new(minion))
			minion.create_effectCount(0, 3, func(paramSelf: Minion):
				paramSelf.add_animation(MinionAnimation.JinBiZhaPianFan.new(paramSelf))
				)
		"洛书龙骨帆":
			var hitPositionList: Array[Vector2] =  GameManager.animationAssets.LuoShuLongGuFan_HitPositionList
			minion.create_clock(3, func(paramSelf: Minion):
				# 从hitbox中随机选择一个位置
				var hitPosition: Vector2 = hitPositionList[randi() % hitPositionList.size()]
				# 再在该位置加载粒子特效
				var particles: LuoShuLongGuFan_Particles = GameManager.animationAssets.LuoShuLongGuFan_Template.instantiate()
				paramSelf.click.add_child(particles)
				particles.position = hitPosition
				# 创建粒子特效完毕后配置点击命中逻辑
				paramSelf.create_click(func(clickPosition: Vector2, _paramSelf: Minion):
					# 如果粒子特效不存在
					if not is_instance_valid(particles):
						return false
					# 如果已经点击过则不判断
					if particles.is_clicked():
						return false
					# 计算距离小于GameManager.animationAssets.LuoShuLongGuFan_HitRadius,则命中
					if clickPosition.distance_to(particles.global_position) < GameManager.animationAssets.LuoShuLongGuFan_HitRadius:
						particles.click()
						_paramSelf.add_animation(MinionAnimation.LuoShuLongGuFan.new(minion))
						return true
					return false
					)
				var stop_emit_timer = paramSelf.click.get_tree().create_timer(2.0)
				stop_emit_timer.timeout.connect(func():
					if is_instance_valid(particles):
						# 停止发射新粒子
						particles.particles.emitting = false
						var cleanup_timer = paramSelf.click.get_tree().create_timer(1)
						cleanup_timer.timeout.connect(func():
							if is_instance_valid(particles):
								particles.queue_free()
						)
				)
				)
		"时渊船长克罗诺斯":
			minion.create_clock(1, func(paramSelf: Minion):
				paramSelf.add_animation(MinionAnimation.ShiYuanChuanZhang.new(paramSelf)))
		"黄金狂潮齐射协议":
			minion.create_boostCount(0)
			minion.create_click(func(clickPosition: Vector2, paramSelf: Minion):
				if GameManager.is_point_in_region(paramSelf.clickRegion, clickPosition):
					if GameManager.is_shopping():
						if GameManager.shopScene.coinRest >= 5:
							GameManager.shopScene.sub_coin(5)
							# 搜索全场海盗牌
							var minionList: Array[Minion] = []
							for card in GameManager.shopScene.deskCardList:
								var targetMinion: Minion = card
								if targetMinion == paramSelf:
									continue
								if targetMinion.get_race() == "海盗":
									minionList.append(targetMinion)
							paramSelf.add_animation(MinionAnimation.HuangJinKuangChao.new(paramSelf, minionList))
						return true
				return false,
				GameManager.animationAssets.HuangJinKuangChao_Sprite,
				GameManager.animationAssets.HuangJinKuangChao_Sprite_Scale,
				func(sprite: Sprite2D, minionInfo: MinionInfo):
				minionInfo.clickIdle = false
				var original_scale = sprite.scale  # 保存原始缩放
				var enlarged_scale = original_scale * 1.2  # 放大 1.5 倍
				var tween = sprite.create_tween()
				tween.tween_property(sprite, "scale", enlarged_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tween.tween_property(sprite, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(sprite, "modulate:a", 0.7, 0.2).set_ease(Tween.EASE_OUT)
				tween.tween_property(sprite, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN)
				await tween.finished
				minionInfo.clickIdle = true
				)
		"刷新畸体":
			# 添加全局效果：免费刷新和额外刷新一个海盗
			GameManager.add_effect(PlayerEffect.FreeFresh.new(4))
			GameManager.add_effect(PlayerEffect.MoreFresh.new(4, func() -> Array[CardInfo]:
				return [MinionData.get_random_minion_in_race_under_level(GameManager.shopMinionInfo, GameManager.shopLevel, "元素")]))
			if GameManager.is_shopping():
				GameManager.shopScene.display_fresh()
		"沼泽游荡者":
			minion.add_animation(MinionAnimation.ZhaoZeYouDangZhe.new(minion))
		"甜点大陆":
			minion.add_animation(MinionAnimation.TianDianDaLu.new(minion))
		"齐恩瓦拉":
			minion.create_effectCount(0, 3, func(paramSelf):
				if GameManager.is_shopping():
					GameManager.shopScene.create_handCard(MinionData.get_random_minion_in_race_under_level(GameManager.shopMinionInfo, GameManager.shopLevel, "元素"), paramSelf.global_position))
		"碎裂巨岩迈沙顿":
			minion.add_animation(MinionAnimation.SuiLieJuYanMaiShaDun.new(minion))
		"永燃火凤":
			minion.create_effectCount(10, 10, func(paramSelf):
				pass)
		"温和的灯神":
			minion.add_animation(MinionAnimation.WenHeDeDengShen.new(minion))
		"大厨诺米":
			minion.create_effectCount(0, 3, func(paramSelf):
				GameManager.handCardLimit += 1)
		"伊辛迪奥斯":
			minion.create_effectCount(0, 4, func(paramSelf):
				paramSelf.add_animation(MinionAnimation.YiXinDiAoSi.new(paramSelf)))
			
# 移除离场
static func remove(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			remove(baseMinion)
	match minion.get_cardName():
		"金币诈骗犯":
			if GameManager.is_shopping():
				GameManager.coinLimit -= minion.get_boostCount()
				GameManager.shopScene.display_coin()
		
# 使用法术
static func use_magic(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			use_magic(baseMinion)
	match minion.get_cardName():
		"时空船长钩尾":
			if GameManager.is_shopping():
				for card in GameManager.shopScene.deskCardList:
					card.add_animation(MinionAnimation.ShiKongChuanZhangGouWei.new(card))

# 使用随从
static func use_minion(minion: Minion, usedMinion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			use_minion(baseMinion, usedMinion)
	match minion.get_cardName():
		"狂放的法力涌流":
			if usedMinion != minion:
				if usedMinion.get_race().contains("元素"):
					# 选择场上的元素牌
					for card in GameManager.shopScene.deskCardList:
						var targetMinion: Minion = card
						if targetMinion.get_race().contains("元素"):
							targetMinion.add_animation(MinionAnimation.KuangFangDeFaLi.new(targetMinion))
		"守护者艾库隆":
			if usedMinion != minion:
				if usedMinion.get_race().contains("元素"):
					usedMinion.add_minionEffect(MinionEffect.RoundShengdun.new(minion.get_spritePath()))
		"齐恩瓦拉":
			if usedMinion != minion:
				if usedMinion.get_race().contains("元素"):
					minion.add_effectCount(1)
		"派对元素":
			if usedMinion.get_race().contains("元素"):
				# 寻找最左侧的随从
				if GameManager.is_shopping():
					var minPosition: Vector2 = Vector2(10000, 0)
					var targetMinion: Minion
					for card in GameManager.shopScene.deskCardList:
						var minionInList: Minion = card
						if minPosition.x > minionInList.global_position.x:
							minPosition.x = minionInList.global_position.x
							targetMinion = minionInList
					if is_instance_valid(targetMinion):
						targetMinion.add_animation(MinionAnimation.PaiDuiYuanSu.new(targetMinion))

# 进击(攻击前触发)
static func attack_before(attackMinion: Minion, behitMinion: Minion) -> void:
	if attackMinion.is_ronghe():
		for baseMinion in attackMinion.minionFather.get_children():
			attack_before(baseMinion, behitMinion)
	match attackMinion.get_cardName():
		"爆裂飓风":
			attackMinion.add_animation(MinionAnimation.BaoLieJuFeng.new(attackMinion))
# 攻击时触发
static func attack_ing(attackMinion: Minion, behitMinion: Minion) -> void:
	if attackMinion.is_ronghe():
		for baseMinion in attackMinion.minionFather.get_children():
			attack_ing(baseMinion, behitMinion)
	match attackMinion.get_cardName():
		"刀剑收藏家":
			attackMinion.add_animation(MinionAnimation.DaoJianShouCangJia.new(attackMinion, behitMinion))
# 攻击后触发
static func attack_after(attackMinion: Minion, behitMinion: Minion) -> void:
	if attackMinion.is_ronghe():
		for baseMinion in attackMinion.minionFather.get_children():
			attack_after(baseMinion, behitMinion)
	match attackMinion.get_cardName():
		"野火元素":
			attackMinion.add_animation(MinionAnimation.YeHuoYuanSu.new(attackMinion, behitMinion))

# 回合开始
static func round_start(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			round_start(baseMinion)
	minion.minionInfo.minionEffectList.round_start(minion)
	match minion.get_cardName():
		"偷金捣蛋鬼":
			minion.add_animation(MinionAnimation.TouJinDaoDanGui.new())
			
# 回合结束
static func round_end(minion: Minion) -> void:
	if minion.is_ronghe():
		for baseMinion in minion.minionFather.get_children():
			round_end(baseMinion)
	match minion.get_cardName():
		"好奇的掠夺者":
			minion.add_animation(MinionAnimation.HaoQiDeLueDuoZhe.new(minion))
		"富饶的基岩":
			minion.add_animation(MinionAnimation.FuRaoDeJiYan.new(minion))
		"溢流熔岩":
			minion.add_animation(MinionAnimation.YiLiuRongYan.new(minion))

# 融合
static func ronghe(newInfo: MinionInfo, minion: Minion, otherMinion: Minion) -> void:
	match minion.get_cardName():
		"增强的光耀之子":
			minion.add_animation(MinionAnimation.ZengQiangDeGuangYao.new(minion))
		"不灭残荷":
			minion.add_animation(MinionAnimation.BuMieCanHe.new(newInfo, minion, otherMinion))
