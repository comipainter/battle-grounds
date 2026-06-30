extends Utils
class_name CardUtils

static func create_card_info(data: CardData) -> CardInfo:
	var info: CardInfo = Utils.convert_object(data, CardInfo)
	info.set_uniqueId(DataManager.get_uniqueId())
	return info

static func create_minion_info(data: MinionData) -> MinionInfo:
	var info: MinionInfo = Utils.convert_object(
		CardUtils.create_card_info(data).copy(),
		MinionInfo
	)
	info.type.set_minion()
	info.set_race(data.get_race())
	info.set_stats(Stats.new(data.get_attack(), data.get_health()))
	info.set_origin_stats(Stats.new(data.get_attack(), data.get_health()))
	info.set_goldenDescription(data.get_goldenDescription())
	info.set_keyword_info(MinionKeywordInfo.new(
		data.get_shengdun(), data.get_chaofeng(), data.get_fengnu()
	))
	info.set_cili(data.is_cili())
	return info

static func create_magic_info(data: MagicData) -> MagicInfo:
	var info: MagicInfo = Utils.convert_object(
		CardUtils.create_card_info(data).copy(),
		MagicInfo
	)
	info.type.set_magic()
	info.set_suzao(data.is_suzao())
	info.set_cost(data.get_cost())
	return info

static func create_card_info_collection(dataCollection: CardDataCollection) -> CardInfoCollection:
	var cardInfoCollection: CardInfoCollection = CardInfoCollection.new()
	for data in dataCollection.get_array():
		cardInfoCollection.add(CardUtils.create_card_info(data))
	return cardInfoCollection

static func create_minion_info_collection(dataCollection: MinionDataCollection) -> MinionInfoCollection:
	var minionInfoCollection: MinionInfoCollection = MinionInfoCollection.new()
	for data in dataCollection.get_array():
		minionInfoCollection.add(CardUtils.create_minion_info(data))
	return minionInfoCollection

static func create_magic_info_collection(dataCollection: MagicDataCollection) -> MagicInfoCollection:
	var magicInfoCollection: MagicInfoCollection = MagicInfoCollection.new()
	for data in dataCollection.get_array():
		magicInfoCollection.add(CardUtils.create_magic_info(data))
	return magicInfoCollection

static func create_card(info: CardInfo) -> Card:
	if info.is_minion():
		var card: Card = DataManager.minionScene.instantiate()
		card.set_info(info)
		if info is MinionInfo and (info as MinionInfo).is_ronghe():
			for baseInfo in (info as MinionInfo).get_base_info_array():
				var base_minion: Card = CardUtils.create_card(baseInfo)
				(card as Minion).ready.connect(
					func():
						(card as Minion).minionFather.add_child(base_minion)
				)
				(base_minion as Minion).ready.connect(
					func():
						(card as Minion).add_base_minion(base_minion)
				)
				
		return card
	elif info.is_magic():
		var card: Card = DataManager.magicScene.instantiate()
		card.set_info(info)
		return card
	else:
		push_error("unknown card type")
		return null

static func create_hand_card(info: CardInfo, position: Vector2, baseCard: Card, _on_card_created: Callable=func(_card:Card):pass) -> void:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_shopping():
			if DataManager.get_shop_info().get_hand_info_collection().size() == DataManager.get_player_info().get_hand_card_num():
				return
			GameManager.mainScene.get_shop_component().get_card_component().card_created.connect(
				_on_card_created, CONNECT_ONE_SHOT
			)
			DataManager.get_shop_info().create_hand_card_info(info, position)
		elif DataManager.get_game_info().is_fighting():
			if baseCard.get_info().is_enemy():
				if DataManager.get_fight_info().get_enemy_hand_info_collection().size() == DataManager.get_enemy_info().get_hand_card_num():
					return
				GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
					_on_card_created, CONNECT_ONE_SHOT
				)
				DataManager.get_fight_info().create_enemy_hand_card_info(info, position)
			elif baseCard.get_info().is_player():
				if DataManager.get_fight_info().get_player_hand_info_collection().size() == DataManager.get_player_info().get_hand_card_num():
					return
				GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
					_on_card_created, CONNECT_ONE_SHOT
				)
				DataManager.get_fight_info().create_player_hand_card_info(info, position)
			else:
				push_error("unknown card belong")
		else:
			push_error("unknown game state")
	else:
		push_error("main scene not vaild when create hand card")
		
static func create_desk_card(info: CardInfo, position: Vector2, baseCard: Card, _on_card_created: Callable=func(_card:Card):pass) -> void:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_shopping():
			if DataManager.get_shop_info().get_desk_info_collection().size() == DataManager.get_player_info().get_desk_card_num():
				return
			GameManager.mainScene.get_shop_component().get_card_component().card_created.connect(
				_on_card_created, CONNECT_ONE_SHOT
			)
			DataManager.get_shop_info().create_desk_card_info(info, position)
		elif DataManager.get_game_info().is_fighting():
			if baseCard.get_info().is_enemy():
				if DataManager.get_fight_info().get_enemy_desk_info_collection().size() == DataManager.get_enemy_info().get_desk_card_num():
					return
				GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
					_on_card_created, CONNECT_ONE_SHOT
				)
				DataManager.get_fight_info().create_enemy_desk_card_info(info, position)
				# 尝试进行更多的创建：专门对应随从：裂谷船长
				for i in range(_check_more_create_desk(get_fighting_enemy_desk_card_collection())):
					if DataManager.get_fight_info().get_enemy_desk_info_collection().size() == DataManager.get_enemy_info().get_desk_card_num():
						continue
					GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
						_on_card_created, CONNECT_ONE_SHOT
					)
					var new_info = info.copy()
					new_info.set_uniqueId(DataManager.get_uniqueId())
					DataManager.get_fight_info().create_enemy_desk_card_info(new_info, position)
			elif baseCard.get_info().is_player():
				if DataManager.get_fight_info().get_player_desk_info_collection().size() == DataManager.get_player_info().get_desk_card_num():
					return
				GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
					_on_card_created, CONNECT_ONE_SHOT
				)
				DataManager.get_fight_info().create_player_desk_card_info(info, position)
				# 尝试进行更多的创建：专门对应随从：裂谷船长
				for i in range(_check_more_create_desk(get_fighting_player_desk_card_collection())):
					if DataManager.get_fight_info().get_player_desk_info_collection().size() == DataManager.get_player_info().get_desk_card_num():
						continue
					GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
						_on_card_created, CONNECT_ONE_SHOT
					)
					var new_info = info.copy()
					new_info.set_uniqueId(DataManager.get_uniqueId())
					DataManager.get_fight_info().create_player_desk_card_info(new_info, position)
			else:
				push_error("unknown card belong")
		else:
			push_error("unknown game state")
	else:
		push_error("main scene not vaild when create desk card")
		
static func create_free_card(info: CardInfo, position: Vector2, baseCard: Card, _on_card_created: Callable=func(_card:Card):pass) -> void:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_shopping():
			GameManager.mainScene.get_shop_component().get_card_component().card_created.connect(
				_on_card_created, CONNECT_ONE_SHOT
			)
			DataManager.get_shop_info().create_free_card_info(info, position)
		elif DataManager.get_game_info().is_fighting():
			if baseCard.get_info().is_enemy():
				GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
					_on_card_created, CONNECT_ONE_SHOT
				)
				DataManager.get_fight_info().create_enemy_free_card_info(info, position)
			elif baseCard.get_info().is_player():
				GameManager.mainScene.get_fight_component().get_card_component().card_created.connect(
					_on_card_created, CONNECT_ONE_SHOT
				)
				DataManager.get_fight_info().create_player_free_card_info(info, position)
			else:
				push_error("unknown card belong")
		else:
			push_error("unknown game state")
	else:
		push_error("main scene not vaild when create hand card")
#
static func remove_card(card: Card) -> void:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_shopping():
			DataManager.get_shop_info().remove_card_info(card.get_info())
		elif DataManager.get_game_info().is_fighting():
			DataManager.get_fight_info().remove_card_info(card.get_info())
		else:
			push_error("unknown game state when remove card")
	else:
		push_error("main scene not vaild when remove card")

static func delete_card(card: Card) -> void:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_shopping():
			DataManager.get_shop_info().delete_card_info(card.get_info())
		elif DataManager.get_game_info().is_fighting():
			DataManager.get_fight_info().delete_card_info(card.get_info())
		else:
			push_error("unknown game state when delete card")
	else:
		push_error("main scene not vaild when delete card")
#
## 找到玩家的这张牌
#static func find_in_player_card(_info: CardInfo) -> CardInfo:
	#if is_instance_valid(GameManager.mainScene):
		## 分别讨论两种情况：
		#if DataManager.get_game_info().is_fighting():
			#return DataManager.get_last_player().get_desk_info_collection().filter_by(
				#CardInfoCollection.Filter.new().set_uniqueId(
					#_info.get_uniqueId()
				#)
			#).get_array().get(0)
		#elif DataManager.get_game_info().is_shopping():
			#return DataManager.get_shop_info().get_desk_info_collection().filter_by(
				#CardInfoCollection.Filter.new().set_uniqueId(
					#_info.get_uniqueId()
				#)
			#).get_array().get(0)
		#else:
			#push_error("game state not vaild when find card")
			#return null
	#else:
		#push_error("main scene not vaild when find card")
		#return null
#
static func get_opponent_card_collection(card: Card) -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_fighting():
			if card.get_info().is_player():
				return GameManager.mainScene.get_fight_component().get_card_component().get_enemy_desk_card_collection()
			elif card.get_info().is_enemy():
				return GameManager.mainScene.get_fight_component().get_card_component().get_player_desk_card_collection()
			else:
				push_error("null opponent for card not belong player or enemy")
				return null
		else:
			push_error("null opponent when unfighting")
			return null
	else:
		push_error("main scene not vaild")
		return null
		
static func get_belong_card_collection(card: Card) -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_fighting():
			if card.get_info().is_player():
				return GameManager.mainScene.get_fight_component().get_card_component().get_player_desk_card_collection()
			elif card.get_info().is_enemy():
				return GameManager.mainScene.get_fight_component().get_card_component().get_enemy_desk_card_collection()
			else:
				push_error("null belong for card not belong player or enemy")
				return null
		elif DataManager.get_game_info().is_shopping():
			if card.get_info().is_desk():
				return GameManager.mainScene.get_shop_component().get_card_component().get_desk_card_collection()
			else:
				push_error("null belong for card")
				return null
		else:
			push_error("null belong when unfighting")
			return null
	else:
		push_error("main scene not vaild")
		return null

static func get_shopping_desk_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_shop_component().get_card_component().get_desk_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null

static func get_shopping_hand_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_shop_component().get_card_component().get_hand_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null
		
static func get_shopping_shop_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_shop_component().get_card_component().get_shop_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null
		
static func get_fighting_player_desk_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_fight_component().get_card_component().get_player_desk_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null

static func get_fighting_player_hand_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_fight_component().get_card_component().get_player_hand_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null

static func get_fighting_enemy_desk_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_fight_component().get_card_component().get_enemy_desk_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null

static func get_fighting_enemy_hand_card_collection() -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		return GameManager.mainScene.get_fight_component().get_card_component().get_enemy_hand_card_collection()
	else:
		push_error("main scene not vaild when get collection")
		return null

static func _check_more_create_desk(collection: CardCollection) -> int:
	var num: int = 0
	for minion: Minion in collection.get_minion_collection().get_array():
		if DataManager.get_game_info().is_fighting():
			if minion.get_info().get_card_name() == "裂骨船长":
				num += 2 if minion.get_info().is_golden() else 1
	return num

static func get_desk_card(baseCard: Card) -> CardCollection:
	if is_instance_valid(GameManager.mainScene):
		if DataManager.get_game_info().is_shopping():
			return GameManager.mainScene.get_shop_component().get_card_component().get_desk_card_collection()
		elif DataManager.get_game_info().is_fighting():
			if baseCard.get_info().is_enemy():
				return GameManager.mainScene.get_fight_component().get_card_component().get_enemy_desk_card_collection()
			elif baseCard.get_info().is_player():
				return GameManager.mainScene.get_fight_component().get_card_component().get_player_desk_card_collection()
			else:
				push_error("unknown card belong")
				return null
		else:
			push_error("unknown game state")
			return null
	else:
		push_error("main scene not vaild when create desk card")
		return null

static func get_belong_player_effect(baseCard: Card) -> PlayerEffectCollection:
	if DataManager.get_game_info().is_fighting():
		if baseCard.get_info().is_player():
			return DataManager.get_player_info().get_player_effect_collection()
		elif baseCard.get_info().is_enemy():
			return DataManager.get_enemy_info().get_player_effect_collection()
	elif DataManager.get_game_info().is_shopping():
		return DataManager.get_player_info().get_player_effect_collection()
	return null

static func overlay_and_time(able: bool) -> void:
	if DataManager.get_game_info().is_shopping():
		if is_instance_valid(GameManager.mainScene):
			if able:
				GameManager.mainScene.get_shop_component().open_overlay()
				GameManager.mainScene.get_shop_component().stop_time()
			else:
				GameManager.mainScene.get_shop_component().close_overlay()
				GameManager.mainScene.get_shop_component().goon_time()
