extends Node

func _ready() -> void:
	_registry()
	GameManager.main_scene_registered.connect(
		func(_main_scene: MainScene):
			var mainScene: MainScene = _main_scene
			var shopComponent: ShopComponent = mainScene.get_shop_component()
			var shopCardComponent: ShopCardComponent = shopComponent.get_card_component()
			var fightComponet: FightComponent = mainScene.get_fight_component()
			var fightCardComponent: FightCardComponent = fightComponet.get_card_component()
			# 卡牌事件总线
			shopCardComponent.card_created.connect(
				func(card: Card):
					# 随从事件总线
					if card.get_info().is_minion():
						var minion: Minion = card as Minion
						_minion_connect(minion)
					# 法术事件总线
					elif card.get_info().is_magic():
						var magic: Magic = card as Magic
						_magic_connect(magic)
					else:
						push_error("unknown card type")
			)
			fightCardComponent.card_created.connect(
				func(card: Card):
					# 随从事件总线
					if card.get_info().is_minion():
						var minion: Minion = card as Minion
						_minion_connect(minion)
					# 法术事件总线
					elif card.get_info().is_magic():
						pass
					else:
						push_error("unknown card type")
			)
			# 商店事件总线
			shopComponent.round_ended.connect(
				func():
					for card in shopCardComponent.get_desk_card_collection().get_array():
						if card.get_info().is_minion():
							_on_round_ended(card)
			)
			shopComponent.used.connect(
				func(used_card: Card):
					if used_card.get_info().is_minion():
						_on_used(used_card)
						_on_zhanhou(used_card)
						for minion in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
							if minion.get_instance_id() != used_card.get_instance_id():
								_on_used_minion(used_card, minion)
					elif used_card.get_info().is_magic():
						_magic_on_used(used_card)
						for minion in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
							_magic_on_used_minion(used_card, minion)
					else:
						push_error("unknown card type")
			)
			shopComponent.round_started.connect(
				func():
					for card in shopCardComponent.get_desk_card_collection().get_array():
						if card.get_info().is_minion():
							_on_round_started(card)
					for minion in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
						minion.get_info().get_effect_collection()._on_round_started(minion)
			)
			shopComponent.brought.connect(
				func(card: Card):
					for minion in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
						_on_brought_minion(card, minion)
			)
			## 以下的信号的连接存在风险：当游戏结束重新开始时，下面的信号仍然保留没有移除
			var shopInfo: ShopInfo = DataManager.get_shop_info()
			var fightInfo: FightInfo = DataManager.get_fight_info()
			shopInfo.coin_added.connect(
				func(_added_coin: int):
					for card in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
						_on_coin_added_minion(_added_coin, card)
			)
			shopInfo.coin_subed.connect(
				func(_subed_coin: int):
					for card in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
						_on_coin_subed_minion(_subed_coin, card)
			)
			shopInfo.hand_added.connect(
				func(info: CardInfo):
					for minion in shopCardComponent.get_desk_card_collection().get_minion_collection().get_array():
						_on_hand_added_minion(info, minion)
			)
			fightInfo.player_desk_added.connect(
				func(info: CardInfo):
					for minion in fightCardComponent.get_player_desk_card_collection().get_minion_collection().get_array():
						_on_desk_added_minion(info, minion)
			)
			fightInfo.enemy_desk_added.connect(
				func(info: CardInfo):
					for minion in fightCardComponent.get_enemy_desk_card_collection().get_minion_collection().get_array():
						_on_desk_added_minion(info, minion)
			)
	)
	
func _minion_connect(minion: Minion) -> void:
	# 随从进击
	minion.attack_befored.connect(_on_attack_befored)
	minion.attack_befored.connect(
		func(_attackedMinion: Minion, _behitMinoin: Minion) -> void:
			for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().erase(minion).get_array():
				_on_attack_befored_minion(_attackedMinion, _behitMinoin, _minion)
	)
	# 随从攻击时
	minion.attack_inged.connect(_on_attack_inged)
	# 随从攻击后
	minion.attack_aftered.connect(_on_attack_aftered)
	# 随从亡语
	minion.dead_after.connect(_on_dead_after)
	minion.dead_after.connect(
		func(dead_minion: Minion) -> void:
			for _minion in CardUtils.get_belong_card_collection(dead_minion).get_minion_collection().erase(dead_minion).get_array():
				_on_dead_after_minion(dead_minion, _minion)
	)
	minion.dead_after.connect(
		func(dead_minion: Minion) -> void:
			dead_minion.get_info().get_effect_collection()._on_dead_after(dead_minion)
	)
	# 随从死亡
	minion.get_info().dead.connect(minion.add_animation.bind(MinionAnimation.DieAnimation.new(minion)))
	# 随从出售
	minion.sold.connect(_on_sold)
	# 随从帧
	minion.processed.connect(
		func(_minion: Minion, delta: float) -> void:
			_minion.get_info().get_effect_collection()._on_processed(_minion, delta)
	)

func _magic_connect(magic: Magic) -> void:
	magic.used.connect(
		func(_used_magic: Magic):
			#_magic_on_used_after(_used_magic)
			for minion in CardUtils.get_desk_card(_used_magic).get_minion_collection().get_array():
				_magic_on_used_after_minion(_used_magic, minion)
	)

func _on_attack_befored(attackMinion: Minion, behitMinion: Minion) -> void:
	attackMinion.add_animation(_match(
		attackMinion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ATTACK_BEFORE,
		[attackMinion, behitMinion]
	))
	for base_attackMinion in attackMinion.get_base_minion_collection().get_array():
			base_attackMinion.add_animation(_match(
			base_attackMinion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ATTACK_BEFORE,
			[base_attackMinion, behitMinion]
		))
		
func _on_attack_inged(attackMinion: Minion, behitMinion: Minion) -> void:
	attackMinion.add_animation(_match(
		attackMinion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ATTACK_ING,
		[attackMinion, behitMinion]
	))
	for base_attackMinion in attackMinion.get_base_minion_collection().get_array():
		base_attackMinion.add_animation(_match(
			base_attackMinion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ATTACK_ING,
			[base_attackMinion, behitMinion]
		))
	
func _on_attack_aftered(attackMinion: Minion, behitMinion: Minion) -> void:
	attackMinion.add_animation(_match(
		attackMinion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ATTACK_AFTER,
		[attackMinion, behitMinion]
	))
	for base_attackMinion in attackMinion.get_base_minion_collection().get_array():
		base_attackMinion.add_animation(_match(
			base_attackMinion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ATTACK_AFTER,
			[base_attackMinion, behitMinion]
		))
			
func _on_attack_befored_minion(attackMinion: Minion, behitMinion: Minion, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ATTACK_BEFORE_MINION,
		[attackMinion, behitMinion, minion]
	))
	for base_attackMinion in attackMinion.get_base_minion_collection().get_array():
		base_attackMinion.add_animation(_match(
			base_attackMinion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ATTACK_BEFORE_MINION,
			[base_attackMinion, behitMinion, minion]
		))
	
func _on_sold(minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.SELL,
		[minion]
	))
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.SELL,
			[base_minion]
		))
	
func _on_round_ended(minion: Minion) -> void:
	var round_ended_count: int = 1
	for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
		if _minion.get_info().get_id() == 68:
			if _minion.get_info().is_golden():
				round_ended_count = 3
				break
			else:
				round_ended_count = 2
	for i in range(round_ended_count):
		minion.add_animation(_match(
			minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ROUND_END,
			[minion]
		))
		minion.get_info().get_effect_collection()._on_round_ended(minion)
		
		for base_minion in minion.get_base_minion_collection().get_array():
			base_minion.add_animation(_match(
				base_minion.get_info().get_card_name(),
				MinionAnimationDefinition.Type.ROUND_END,
				[base_minion]
			))
			base_minion.get_info().get_effect_collection()._on_round_ended(base_minion)
	
func _on_used(minion: Minion) -> void:
	if minion.get_info().is_golden():
		minion.add_animation(MinionUseAnimation.SanLian.new(minion))
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.USE,
		[minion]
	))
	minion.get_info().get_effect_collection()._on_use_minion(minion)
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.USE,
			[base_minion]
		))
		base_minion.get_info().get_effect_collection()._on_use_minion(base_minion)
	
func _magic_on_used(magic: Magic) -> void:
	magic.add_animation(_magic_match(
		magic.get_info().get_card_name(),
		MagicAnimationDefinition.Type.USE,
		[magic]
	))
	
func _magic_on_used_minion(magic: Magic, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.USE_MAGIC_PLAYER,
		[magic, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.USE_MAGIC_PLAYER,
			[magic, base_minion]
		))
	
func _magic_on_used_after_minion(magic: Magic, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.USE_MAGIC,
		[magic, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.USE_MAGIC,
			[magic, base_minion]
		))
	
func _on_zhanhou(minion: Minion) -> void:
	var zhanhou_count: int = 1
	for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
		if _minion.get_info().get_id() == 66:
			if _minion.get_info().is_golden():
				zhanhou_count = 3
				break
			else:
				zhanhou_count = 2
	for i in range(zhanhou_count):
		if minion.get_info().is_ronghe() == false:
			minion.add_animation(_match(
				minion.get_info().get_card_name(),
				MinionAnimationDefinition.Type.ZHANHOU,
				[minion]
			))
		else:
			for base_minion in minion.get_base_minion_collection().get_array():
				if is_instance_valid(base_minion) == false:
					continue
				base_minion.add_animation(_match(
					base_minion.get_info().get_card_name(),
					MinionAnimationDefinition.Type.ZHANHOU,
					[base_minion]
				))
				while is_instance_valid(base_minion) and base_minion.is_idle() == false:
					await get_tree().process_frame
	
func _on_used_minion(usedminion: Minion, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.USE_MINION,
		[usedminion, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.USE_MINION,
			[usedminion, base_minion]
		))
	
func _on_dead_after(minion: Minion) -> void:
	var wangyu_count: int = 1
	for _minion in CardUtils.get_belong_card_collection(minion).get_minion_collection().get_array():
		if _minion.get_info().get_id() == 67:
			if _minion.get_info().is_golden():
				wangyu_count += 2
			else:
				wangyu_count += 1
	for i in range(wangyu_count):
		minion.add_animation(_match(
			minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.DIE_AFTER,
			[minion]
		))
		
		for base_minion in minion.get_base_minion_collection().get_array():
			base_minion.add_animation(_match(
				base_minion.get_info().get_card_name(),
				MinionAnimationDefinition.Type.DIE_AFTER,
				[base_minion]
			))

func _on_dead_after_minion(dead_minion: Minion, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.DIE_AFTER_MINION,
		[dead_minion, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.DIE_AFTER_MINION,
			[dead_minion, base_minion]
		))
		
func _on_round_started(minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ROUND_START,
		[minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ROUND_START,
			[base_minion]
		))

func _on_coin_added_minion(_added_coin: int, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.COIN_ADD,
		[_added_coin, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.COIN_ADD,
			[_added_coin, base_minion]
		))

func _on_coin_subed_minion(_subed_coin: int, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.COIN_SUB,
		[_subed_coin, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.COIN_SUB,
			[_subed_coin, base_minion]
		))

func _on_brought_minion(_brought_card: Card, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.BUY,
		[_brought_card, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.BUY,
			[_brought_card, base_minion]
		))

func _on_hand_added_minion(info: CardInfo, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ADD_HAND,
		[info, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ADD_HAND,
			[info, base_minion]
		))
		
func _on_desk_added_minion(info: CardInfo, minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.ADD_DESK,
		[info, minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.ADD_DESK,
			[info, base_minion]
		))
		
func _on_liejied(be_liejied_minion: Minion) -> void:
	pass
		
func _on_liejied_minion(minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.LIEJIE_MINION,
		[minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.LIEJIE_MINION,
			[base_minion]
		))
		
func _on_ronghed(ronghe_minion: Minion, minion1: Minion, minion2: Minion) -> void:
	minion1.add_animation(_match(
		minion1.get_info().get_card_name(),
		MinionAnimationDefinition.Type.BE_RONGHE,
		[ronghe_minion, minion1, minion2]
	))
	
	for base_minion in minion1.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.BE_RONGHE,
			[ronghe_minion, minion1, minion2]
		))
	
	minion2.add_animation(_match(
		minion2.get_info().get_card_name(),
		MinionAnimationDefinition.Type.BE_RONGHE,
		[ronghe_minion, minion2, minion1]
	))
	
	for base_minion in minion2.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.BE_RONGHE,
			[ronghe_minion, minion2, minion1]
		))
		
func _on_ronghed_minion(minion: Minion) -> void:
	minion.add_animation(_match(
		minion.get_info().get_card_name(),
		MinionAnimationDefinition.Type.RONGHE_MINION,
		[minion]
	))
	
	for base_minion in minion.get_base_minion_collection().get_array():
		base_minion.add_animation(_match(
			base_minion.get_info().get_card_name(),
			MinionAnimationDefinition.Type.RONGHE_MINION,
			[base_minion]
		))
	
var _map: Dictionary = {}

func _match(
	card_name: String, 
	type: MinionAnimationDefinition.Type,
	args: Array
) -> BaseAnimation:
	if not _map.has(card_name):
		return
	if not _map[card_name].has(type):
		return
	return _map[card_name][type].callv(args)

func _register(
	card_name: String, 
	type: MinionAnimationDefinition.Type,
	init_func: Callable
) -> void:
	if not _map.has(card_name):
		_map[card_name] = {}
	_map[card_name][type] = init_func
	
var _magic_map: Dictionary = {}
func _magic_match(
	card_name: String, 
	type: MagicAnimationDefinition.Type,
	args: Array
) -> BaseAnimation:
	if not _magic_map.has(card_name):
		return
	if not _magic_map[card_name].has(type):
		return
	return _magic_map[card_name][type].callv(args)
func _magic_register(
	card_name: String, 
	type: MagicAnimationDefinition.Type,
	init_func: Callable
) -> void:
	if not _magic_map.has(card_name):
		_magic_map[card_name] = {}
	_magic_map[card_name][type] = init_func

func _registry() -> void:
	# 随从
	_register(
		"爆裂飓风", 
		MinionAnimationDefinition.Type.ATTACK_BEFORE, 
		MinionAttackBeforeAnimation.BaoLieJuFeng.new
	)
	_register(
		"商贩元素", 
		MinionAnimationDefinition.Type.SELL, 
		MinionSellAnimation.ShangFanYuanSu.new
	)
	_register(
		"富饶的基岩", 
		MinionAnimationDefinition.Type.ROUND_END, 
		MinionRoundEndAnimation.FuRaoDeJiYan.new
	)
	_register(
		"野火元素", 
		MinionAnimationDefinition.Type.ATTACK_AFTER, 
		MinionAttackAfterAnimation.YeHuoYuanSu.new
	)
	_register(
		"派对元素", 
		MinionAnimationDefinition.Type.USE_MINION, 
		MinionUseMinionAnimation.PaiDuiYuanSu.new
	)
	_register(
		"刷新畸体", 
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.ShuaXinJiTi.new
	)
	_register(
		"沼泽游荡者", 
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.ZhaoZeYouDangZhe.new
	)
	_register(
		"狂放的法力涌流", 
		MinionAnimationDefinition.Type.USE_MINION, 
		MinionUseMinionAnimation.KuangFangDeFaLiYongLiu.new
	)
	_register(
		"守护者艾库隆", 
		MinionAnimationDefinition.Type.USE_MINION, 
		MinionUseMinionAnimation.ShouHuZheAiKuLong.new
	)
	_register(
		"甜点大陆",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.TianDianDaLu.new
	)
	_register(
		"齐恩瓦拉",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.QiEnWaLa.new
	)
	_register(
		"齐恩瓦拉",
		MinionAnimationDefinition.Type.USE_MINION, 
		MinionUseMinionAnimation.QiEnWaLa.new
	)
	_register(
		"溢流熔岩",
		MinionAnimationDefinition.Type.ROUND_END, 
		MinionRoundEndAnimation.YiLiuRongYan.new
	)
	_register(
		"碎裂巨岩迈沙顿",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.SuiYanMaiShaDun.new
	)
	_register(
		"永燃火凤",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.YongRanHuoFeng.new
	)
	_register(
		"永燃火凤",
		MinionAnimationDefinition.Type.DIE_AFTER, 
		MinionDieAfterAnimation.YongRanHuoFeng.new
	)
	_register(
		"温和的灯神",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.WenHeDeDengShen.new
	)
	_register(
		"大厨诺米",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.DaChuNuoMi.new
	)
	_register(
		"大厨诺米",
		MinionAnimationDefinition.Type.ADD_HAND, 
		MinionAddHandAnimation.DaChuNuoMi.new
	)
	_register(
		"增强的光耀之子",
		MinionAnimationDefinition.Type.LIEJIE_MINION, 
		MinionLiejieMinionAnimation.ZengQiangDeGuangYaoZhiZi.new
	)
	_register(
		"增强的光耀之子",
		MinionAnimationDefinition.Type.RONGHE_MINION, 
		MinionRongheMinionAnimation.ZengQiangDeGuangYaoZhiZi.new
	)
	_register(
		"灾变飓风斯卡尔",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.ZaiBianJuFengSiKaEr.new
	)
	_register(
		"伊辛迪奥斯",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.YiXinDiAoSi.new
	)
	_register(
		"伊辛迪奥斯",
		MinionAnimationDefinition.Type.DIE_AFTER_MINION, 
		MinionDieAfterMinionAnimation.YiXinDiAoSi.new
	)
	_register(
		"不灭残荷",
		MinionAnimationDefinition.Type.BE_RONGHE, 
		MinionRongheAnimation.BuMieCanHe.new
	)
	_register(
		"海盗无赖",
		MinionAnimationDefinition.Type.DIE_AFTER, 
		MinionDieAfterAnimation.HaiDaoWuLai.new
	)
	_register(
		"南海卖艺者",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.NanHaiMaiYiZhe.new
	)
	_register(
		"白赚赌徒",
		MinionAnimationDefinition.Type.SELL, 
		MinionSellAnimation.BaiZhuanDuTu.new
	)
	_register(
		"海上走私贩",
		MinionAnimationDefinition.Type.DIE_AFTER, 
		MinionDieAfterAnimation.HaiShangZouSiFan.new
	)
	_register(
		"撕心狼队长",
		MinionAnimationDefinition.Type.ATTACK_BEFORE_MINION, 
		MinionAttackBeforeMinionAnimation.SiXinLangDuiZhang.new
	)
	_register(
		"尸体提炼师",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.ShiTiTiLianShi.new
	)
	_register(
		"尸体提炼师",
		MinionAnimationDefinition.Type.DIE_AFTER_MINION, 
		MinionDieAfterMinionAnimation.ShiTiTiLianShi.new
	)
	_register(
		"时空船长钩尾",
		MinionAnimationDefinition.Type.USE_MAGIC, 
		MinionUseMagicAnimation.ShiKongChuanZhangGouWei.new
	)
	_register(
		"刀剑收藏家",
		MinionAnimationDefinition.Type.ATTACK_BEFORE, 
		MinionAttackBeforeAnimation.DaoJianShouCangJia.new
	)
	_register(
		"顽砂猎头",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.WanShaLieTou.new
	)
	_register(
		"海浪剃刀号",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.HaiLangTiDaoHao.new
	)
	_register(
		"海浪剃刀号",
		MinionAnimationDefinition.Type.DIE_AFTER_MINION, 
		MinionDieAfterMinionAnimation.HaiLangTiDaoHao.new
	)
	_register(
		"金枪格蕾塔",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.JinQiangGeLeiTa.new
	)
	_register(
		"金枪格蕾塔",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.JinQiangGeLeiTa.new
	)
	_register(
		"偷金捣蛋鬼",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.TouJinDaoDanGui.new
	)
	_register(
		"金币诈骗犯",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.JinBiZhaPianFan.new
	)
	_register(
		"金币诈骗犯",
		MinionAnimationDefinition.Type.COIN_ADD, 
		MinionCoinAddAnimation.JinBiZhaPianFan.new
	)
	_register(
		"金币诈骗犯",
		MinionAnimationDefinition.Type.SELL, 
		MinionSellAnimation.JinBiZhaPianFan.new
	)
	_register(
		"咒缚海员",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.ZhouFuHaiYuan.new
	)
	_register(
		"咒缚海员",
		MinionAnimationDefinition.Type.BUY, 
		MinionBuyAnimation.ZhouFuHaiYuan.new
	)
	_register(
		"德鲁斯特",
		MinionAnimationDefinition.Type.ADD_HAND, 
		MinionAddHandAnimation.DeLuSiTe.new
	)
	_register(
		"亡灵舰长伊丽扎",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.WangLingJianZhangYiLiZha.new
	)
	_register(
		"亡灵舰长伊丽扎",
		MinionAnimationDefinition.Type.ATTACK_BEFORE_MINION, 
		MinionAttackBeforeMinionAnimation.WangLingJianZhangYiLiZha.new
	)
	_register(
		"空军上将罗杰斯",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.KongJunShangJiangLuoJieSi.new
	)
	_register(
		"空军上将罗杰斯",
		MinionAnimationDefinition.Type.COIN_SUB, 
		MinionCoinSubAnimation.KongJunShangJiangLuoJieSi.new
	)
	_register(
		"黄金狂潮齐射协议",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.HuangJinKuangChaoQiSheXieYi.new
	)
	_register(
		"好奇的掠夺者",
		MinionAnimationDefinition.Type.ROUND_END, 
		MinionRoundEndAnimation.HaoQiDeLueDuoZhe.new
	)
	_register(
		"海上双雄",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.HaiShangShuangXiong.new
	)
	_register(
		"海上双雄",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.HaiShangShuangXiong.new
	)
	_register(
		"角逗士",
		MinionAnimationDefinition.Type.USE_MAGIC, 
		MinionUseMagicAnimation.JiaoDouShi.new
	)
	_register(
		"贝类收藏家",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.BeiLeiShouCangJia.new
	)
	_register(
		"杂耍奇术师",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.ZaShuaQiShuShi.new
	)
	_register(
		"杂耍奇术师",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.ZaShuaQiShuShi.new
	)
	_register(
		"热情沙锤手",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.ReQingShaChuiShou.new
	)
	_register(
		"热情沙锤手",
		MinionAnimationDefinition.Type.USE_MAGIC_PLAYER, 
		MinionUseMagicPlayerAnimation.ReQingShaChuiShou.new
	)
	_register(
		"热情沙锤手",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.ReQingShaChuiShou.new
	)
	_register(
		"海床招募者",
		MinionAnimationDefinition.Type.ATTACK_BEFORE, 
		MinionAttackBeforeAnimation.HaiChuangZhaoMuZhe.new
	)
	_register(
		"乘波骑士",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.ChengBoQishi.new
	)
	_register(
		"乘波骑士",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.ChengBoQishi.new
	)
	_register(
		"库斯卡工兵",
		MinionAnimationDefinition.Type.DIE_AFTER, 
		MinionDieAfterAnimation.KuSiKaGongBing.new
	)
	_register(
		"古神的卫士",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.GuShenDeWeiShi.new
	)
	_register(
		"古神的卫士",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.GuShenDeWeiShi.new
	)
	_register(
		"滑道滑行者",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.HuaDaoHuaXingZhe.new
	)
	_register(
		"滑道滑行者",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.HuaDaoHuaXingZhe.new
	)
	_register(
		"照看者奥戈佐亚",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.ZhaoKanZheAoGeZuoYa.new
	)
	_register(
		"肌肉领主滑矛",
		MinionAnimationDefinition.Type.ROUND_END, 
		MinionRoundEndAnimation.JiRouLingZhuHuaMao.new
	)
	_register(
		"奥术火炮手",
		MinionAnimationDefinition.Type.ATTACK_BEFORE, 
		MinionAttackBeforeAnimation.AoShuHuoPaoShou.new
	)
	_register(
		"柔心海妖",
		MinionAnimationDefinition.Type.ROUND_END, 
		MinionRoundEndAnimation.RouXinHaiYao.new
	)
	_register(
		"显眼的骑手",
		MinionAnimationDefinition.Type.DIE_AFTER, 
		MinionDieAfterAnimation.XianYanDeQiShou.new
	)
	_register(
		"暗潮战略专家",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.AnChaoZhanLueZhuanJia.new
	)
	_register(
		"暗潮战略专家",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.AnChaoZhanLueZhuanJia.new
	)
	_register(
		"暗潮战略专家",
		MinionAnimationDefinition.Type.ROUND_END, 
		MinionRoundEndAnimation.AnChaoZhanLueZhuanJia.new
	)
	_register(
		"破碎主母",
		MinionAnimationDefinition.Type.USE_MAGIC, 
		MinionUseMagicAnimation.PoSuiZhuMu.new
	)
	_register(
		"希里瓦兹",
		MinionAnimationDefinition.Type.ROUND_START, 
		MinionRoundStartAnimation.XiLiWaZi.new
	)
	_register(
		"希里瓦兹",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.XiLiWaZi.new
	)
	_register(
		"希里瓦兹",
		MinionAnimationDefinition.Type.USE_MAGIC_PLAYER, 
		MinionUseMagicPlayerAnimation.XiLiWaZi.new
	)
	_register(
		"奇术狂想家",
		MinionAnimationDefinition.Type.ZHANHOU, 
		MinionZhanhouAnimation.QiShuKuangXiangJia.new
	)
	_register(
		"碎地者",
		MinionAnimationDefinition.Type.USE_MINION, 
		MinionUseMinionAnimation.SuiDiZhe.new
	)
	_register(
		"风暴分流者",
		MinionAnimationDefinition.Type.USE, 
		MinionUseAnimation.FengBaoFenLiuZhe.new
	)
	_register(
		"风暴分流者",
		MinionAnimationDefinition.Type.USE_MAGIC_PLAYER, 
		MinionUseMagicPlayerAnimation.FengBaoFenLiuZhe.new
	)
	_register(
		"竞技表演者",
		MinionAnimationDefinition.Type.ZHANHOU,
		MinionZhanhouAnimation.JingJiBiaoYanZhe.new
	)
	_register(
		"蓝壳始祖龟",
		MinionAnimationDefinition.Type.SELL,
		MinionSellAnimation.LanKeShiZuGui.new
	)
	_register(
		"耐心的侦查员",
		MinionAnimationDefinition.Type.USE,
		MinionUseAnimation.NaiXinDeZhenChaYuan.new
	)
	_register(
		"耐心的侦查员",
		MinionAnimationDefinition.Type.ROUND_END,
		MinionRoundEndAnimation.NaiXinDeZhenChaYuan.new
	)
	_register(
		"耐心的侦查员",
		MinionAnimationDefinition.Type.SELL,
		MinionSellAnimation.NaiXinDeZhenChaYuan.new
	)
		
	
	
	
	
	
	
	
	
	
	
	
	# 法术
	_magic_register(
		"酒馆币",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.JiuGuanBi.new
	)
	_magic_register(
		"酒馆币",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.JiuGuanBi.new
	)
	_magic_register(
		"三连奖励",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.SanLianJiangLi.new
	)
	_magic_register(
		"三连奖励",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.SanLianJiangLi.new
	)
	_magic_register(
		"掠夺者合约",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.LueDuoZheHeYue.new
	)
	_magic_register(
		"掠夺者合约",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.LueDuoZheHeYue.new
	)
	_magic_register(
		"海潮的祝福",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.HaiChaoDeZhuFu.new
	)
	_magic_register(
		"海潮的祝福",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.HaiChaoDeZhuFu.new
	)
	_magic_register(
		"奇术杂耍",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.ZaShuaQiShu.new
	)
	_magic_register(
		"奇术杂耍",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.ZaShuaQiShu.new
	)
	_magic_register(
		"奇术杂耍",
		MagicAnimationDefinition.Type.POINTED_USE,
		MagicPointedUseAnimation.ZaShuaQiShu.new
	)
	_magic_register(
		"深沉蓝调",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.ShenChenLanDiao.new
	)
	_magic_register(
		"深沉蓝调",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.ShenChenLanDiao.new
	)
	_magic_register(
		"骑士的祝福",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.QiShiDeZhuFu.new
	)
	_magic_register(
		"骑士的祝福",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.QiShiDeZhuFu.new
	)
	_magic_register(
		"古神的祝福",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.GuShenDeZhuFu.new
	)
	_magic_register(
		"古神的祝福",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.GuShenDeZhuFu.new
	)
	_magic_register(
		"滑道滑行术",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.HuaDaoHuaXingShu.new
	)
	_magic_register(
		"滑道滑行术",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.HuaDaoHuaXingShu.new
	)
	_magic_register(
		"暗流涌动",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.AnLiuYongDong.new
	)
	_magic_register(
		"暗流涌动",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.AnLiuYongDong.new
	)
	_magic_register(
		"奇术狂想",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.QiShuKuangXiang.new
	)
	_magic_register(
		"奇术狂想",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.QiShuKuangXiang.new
	)
	_magic_register(
		"娜迦归潮",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.NaJiaGuiChao.new
	)
	_magic_register(
		"娜迦归潮",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.NaJiaGuiChao.new
	)
	_magic_register(
		"友方悬赏令",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.YouFangXuanShangLing.new
	)
	_magic_register(
		"友方悬赏令",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.YouFangXuanShangLing.new
	)
	_magic_register(
		"财富悬赏令",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.CaiFuXuanShangLing.new
	)
	_magic_register(
		"财富悬赏令",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.CaiFuXuanShangLing.new
	)
	_magic_register(
		"战斗悬赏令",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.ZhanDouXuanShangLing.new
	)
	_magic_register(
		"战斗悬赏令",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.ZhanDouXuanShangLing.new
	)
	_magic_register(
		"金色大衍术",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.JinSeDaYanShu.new
	)
	_magic_register(
		"金色大衍术",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.JinSeDaYanShu.new
	)
	_magic_register(
		"香蕉果盘",
		MagicAnimationDefinition.Type.USE,
		MagicUseAnimation.XiangQiaoGuoPan.new
	)
	_magic_register(
		"香蕉果盘",
		MagicAnimationDefinition.Type.AUTO_USE,
		MagicAutoUseAnimation.XiangQiaoGuoPan.new
	)
