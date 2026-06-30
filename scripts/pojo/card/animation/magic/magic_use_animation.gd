extends MagicAnimation
class_name MagicUseAnimation

var magic: Magic
func _init(_magic: Magic) -> void:
	magic =  _magic
	
func play() -> void:
	magic.used.emit(magic)
	magic.add_animation(MagicAnimation.DeleteAnimation.new(magic))
	
class JiuGuanBi extends MagicUseAnimation:
	func play() -> void:
		DataManager.get_shop_info().add_coin(1)
		super.play()

class SanLianJiangLi extends MagicUseAnimation:
	func play() -> void:
		var choice_data_array: Array[MinionData] = []
		for i in range(3):
			choice_data_array.append(
				DataManager.get_sellable_minion_data().filter_by(
					MinionDataCollection.Filter.new().set_level(
						mini(
							DataManager.get_shop_info().get_level()+1,
							ShopConstant.get_max_level()
						)
					)
				).pick_random()
			)
		var faxianAnimation = PlayerAniamtion.FaXianChoose.new(choice_data_array)
		GameManager.get_main_scene().get_player_component().add_animation(
			faxianAnimation
		)
		var choosedIndex: int = await faxianAnimation.choice_made
		if choosedIndex != null:
			CardUtils.create_hand_card(
				CardUtils.create_minion_info(choice_data_array[choosedIndex]),
				Vector2.ZERO,
				magic
			)
		super.play()

class LueDuoZheHeYue extends MagicUseAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			var collection: MinionInfoCollection = DataManager.get_shop_info().get_shop_info_collection().get_minion_collection().filter_by(
				MinionInfoCollection.Filter.new().set_race(
					Race.Type.HaiDao
				)
			)
			if collection.size() != 0:
				DataManager.get_shop_info().move_card_to_hand(
					collection.pick_random()
				)
		super.play()

class HaiChaoDeZhuFu extends MagicUseAnimation:
	func play() -> void:
		var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(
			CardUtils.get_shopping_desk_card_collection().get_minion_collection()
		)
		GameManager.get_main_scene().get_player_component().add_animation(
			zhanhouAnimation
		)
		var choosedMinion: Minion = await zhanhouAnimation.choice_made
		choosedMinion.get_info().get_effect_collection().add_minion_effect(
			MinionEffect_HaiChaoDeZhuFu.new()
		)
		super.play()

class ZaShuaQiShu extends MagicUseAnimation:
	func play() -> void:
		var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(
			CardUtils.get_shopping_desk_card_collection().get_minion_collection()
		)
		GameManager.get_main_scene().get_player_component().add_animation(
			zhanhouAnimation
		)
		var choosedMinion: Minion = await zhanhouAnimation.choice_made
		var stats: Stats = StatsUtils.mul_stats(
			Stats.new(1, 1),
			(CardUtils.get_belong_player_effect(magic).find_effect(
				Effect_UseMagic
			) as Effect_UseMagic).get_value()+1
		)
		stats.add_stats(
			(CardUtils.get_belong_player_effect(magic).find_effect(
				Effect_SuZaoStatsBuff
			)as Effect_SuZaoStatsBuff).get_stats()
		)
		choosedMinion.get_info().get_effect_collection().add_minion_effect(
			MinionEffect_QiShuZaShuai.new(
				stats,
				choosedMinion.get_info()
			)
		)
		super.play()

class ShenChenLanDiao extends MagicUseAnimation:
	func play() -> void:
		var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(
			CardUtils.get_shopping_desk_card_collection().get_minion_collection()
		)
		GameManager.get_main_scene().get_player_component().add_animation(
			zhanhouAnimation
		)
		var choosedMinion: Minion = await zhanhouAnimation.choice_made
		MinionUtils.add_stats_from_magic(
			magic,
			choosedMinion,
			StatsUtils.mul_stats(
				Stats.new(3, 3),
				(CardUtils.get_belong_player_effect(magic).find_effect(
					Effect_UseShenchenlandiao
				) as Effect_UseShenchenlandiao).get_value()+1
			)
		)
		super.play()

class QiShiDeZhuFu extends MagicUseAnimation:
	func play() -> void:
		var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(
			CardUtils.get_shopping_desk_card_collection().get_minion_collection()
		)
		GameManager.get_main_scene().get_player_component().add_animation(
			zhanhouAnimation
		)
		var choosedMinion: Minion = await zhanhouAnimation.choice_made
		choosedMinion.get_info().get_keyword_info().set_shengdun(true)
		super.play()

class GuShenDeZhuFu extends MagicUseAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			DataManager.get_shop_info().add_coin(1)
		if randi_range(0, 1) == 0:
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"古神的祝福"
						)
					).get_array().front()
				),
				magic.global_position,
				magic
			)
		super.play()

class HuaDaoHuaXingShu extends MagicUseAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			GameManager.get_main_scene().get_shop_component().get_fresh_component().fresh()
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_suzao(true).set_level_range(
							1,
							DataManager.get_shop_info().get_level()
						)
					).pick_random()
				),
				magic.global_position,
				magic
			)
		super.play()

class AnLiuYongDong extends MagicUseAnimation:
	func play() -> void:
		CardUtils.create_hand_card(
			CardUtils.create_minion_info(
				DataManager.get_sellable_minion_data().filter_by(
					MinionDataCollection.Filter.new().set_race(
						Race.Type.NaJia
					).set_level(
						maxi(magic.get_info().get_boost_counter_info().get_count(), 1)
					)
				).pick_random()
			),
			magic.global_position,
			magic
		)
		super.play()

class QiShuKuangXiang extends MagicUseAnimation:
	signal magic_deleted
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			var magicData: MagicData = DataManager.get_all_magic_data().filter_by(
				MagicDataCollection.Filter.new().set_name(
					"奇术杂耍"
				)
			).get_array().front()
			CardUtils.overlay_and_time(true)
			for _minion in CardUtils.get_desk_card(magic).get_minion_collection().get_array():
				CardUtils.create_free_card(
					CardUtils.create_magic_info(magicData),
					magic.global_position,
					magic,
					func(_card: Card):
						(_card as Magic).deleted.connect(magic_deleted.emit)
						_card.add_animation(AnimationManager._magic_match(
							_card.get_info().get_card_name(),
							MagicAnimationDefinition.Type.POINTED_USE,
							[_card, _minion]
						))
				)
				await magic_deleted
			CardUtils.overlay_and_time(false)
		super.play()

class NaJiaGuiChao extends MagicUseAnimation:
	signal magic_deleted
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			CardUtils.overlay_and_time(true)
			for _magicInfo: MagicInfo in (
				CardUtils.get_belong_player_effect(magic).find_effect(
				Effect_RoundMagicRecord
			) as Effect_RoundMagicRecord).get_array().duplicate():
				if _magicInfo.is_suzao():
					## 如果创建手牌需要检测手牌数量，这里使用创建free不需要检测
					#if DataManager.get_shop_info().get_hand_info_collection().size() < DataManager.get_player_info().get_hand_card_num():
					CardUtils.create_free_card(
						_magicInfo,
						magic.global_position,
						magic,
						func(_card: Card):
							(_card as Magic).deleted.connect(magic_deleted.emit)
							_card.add_animation(AnimationManager._magic_match(
								_card.get_info().get_card_name(),
								MagicAnimationDefinition.Type.AUTO_USE,
								[_card]
							))
					)
					await magic_deleted
			CardUtils.overlay_and_time(false)
		super.play()

class YouFangXuanShangLing extends MagicUseAnimation:
	func play() -> void:
		var most_race: Race.Type = CardUtils.get_desk_card(magic).get_minion_collection().get_most_race()
		if most_race == Race.Type.None:
			super.play()
			return
		else:
			# 随机获取一张你多数随从的类型的随从牌
			CardUtils.create_hand_card(
				CardUtils.create_minion_info(
					DataManager.get_sellable_minion_data().filter_by(
						MinionDataCollection.Filter.new().set_race(
							most_race
						).set_level_range(
							1, DataManager.get_shop_info().get_level()
						)
					).pick_random()
				),
				magic.global_position,
				magic
			)
		super.play()

class CaiFuXuanShangLing extends MagicUseAnimation:
	func play() -> void:
		DataManager.get_player_info().get_player_effect_collection().add_player_effect(
			Effect_CaiFu.new()
		)
		super.play()

class ZhanDouXuanShangLing extends MagicUseAnimation:
	func play() -> void:
		var collection: MinionCollection = CardUtils.get_desk_card(magic).get_minion_collection()
		if collection.size() == 0:
			super.play()
			return
		else:
			for minion in collection.pick_random_collection(
				mini(collection.size(), 3),
				false
			).get_array():
				MinionUtils.add_stats_from_magic(
					magic,minion,Stats.new(4, 4)
				)
			super.play()

class JinSeDaYanShu extends MagicUseAnimation:
	func play() -> void:
		var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(
			CardUtils.get_shopping_desk_card_collection().get_minion_collection()
		)
		GameManager.get_main_scene().get_player_component().add_animation(
			zhanhouAnimation
		)
		var choosedMinion: Minion = await zhanhouAnimation.choice_made
		choosedMinion.get_info().get_effect_collection().add_minion_effect(
			MinionEffect_JinSeDaYanShu.new(choosedMinion.get_info())
		)
		super.play()

class XiangQiaoGuoPan extends MagicUseAnimation:
	func play() -> void:
		var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(
			CardUtils.get_shopping_desk_card_collection().get_minion_collection()
		)
		GameManager.get_main_scene().get_player_component().add_animation(
			zhanhouAnimation
		)
		var choosedMinion: Minion = await zhanhouAnimation.choice_made
		MinionUtils.add_stats_from_magic(magic, choosedMinion, Stats.new(2, 2))
		super.play()
