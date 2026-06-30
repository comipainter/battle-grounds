### 回合结束
extends MinionAnimation
class_name MinionZhanhouAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion

func play() -> void:
	pass

class ShuaXinJiTi extends MinionZhanhouAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			DataManager.get_player_info().get_player_effect_collection().add_player_effect(
				Effect_FreeFresh.new(
					8 if minion.get_info().is_golden() else 4
				)
			)
			DataManager.get_player_info().get_player_effect_collection().add_player_effect(
				Effect_SpecialFresh.new(
					4,
					func():
						DataManager.get_shop_info().create_shop_card_info(
							CardUtils.create_minion_info(
								DataManager.get_sellable_minion_data().filter_by(
									MinionDataCollection.Filter.new().set_race(
										Race.Type.YuanSu
									).set_level_range(1, DataManager.get_shop_info().get_level())
								).pick_random()
							),
							Vector2(10000, 0)
						)
			)
			)

class ZhaoZeYouDangZhe extends MinionZhanhouAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			var collection: MinionCollection = MinionCollection.new().add_collection(
				CardUtils.get_shopping_desk_card_collection().get_minion_collection()
			).erase(minion).remove_unvaild().remove_father(minion)
			for _minion: Minion in collection.get_array().duplicate():
				if _minion.get_info().get_id() == 28:
					collection.erase(_minion)
				for _base_minion: Minion in _minion.get_base_minion_collection().get_array():
					if _base_minion.get_info().get_id() == 28:
						collection.erase(_minion)
						break
			if collection == null or collection.size() == 0:
				return
			var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(collection)
			GameManager.get_main_scene().get_player_component().add_animation(
				zhanhouAnimation
			)
			var choosedMinion: Minion = await zhanhouAnimation.choice_made
			if is_instance_valid(choosedMinion):
				DataManager.get_shop_info().move_card_to_hand(choosedMinion.get_info())
				for i in range(2 if minion.get_info().is_golden() else 1):
					choosedMinion.get_info().add_stats(Stats.new(1, 1))

class TianDianDaLu extends MinionZhanhouAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			for i in range(
				4 if minion.get_info().is_golden() else 2
			):
				CardUtils.create_hand_card(
					CardUtils.create_minion_info(
						DataManager.get_all_minion_data().filter_by(
							MinionDataCollection.Filter.new().set_name("甜蜜元素")
						).get_array().front()
					),
					minion.global_position,
					minion
				)

class SuiYanMaiShaDun extends MinionZhanhouAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			var collection: MinionCollection = MinionCollection.new().add_collection(
				CardUtils.get_shopping_desk_card_collection().get_minion_collection().filter_by(
					MinionCollection.Filter.new().set_except_name(minion.get_info().get_card_name())
				)
			).remove_unvaild().remove_father(minion)
			if collection == null or collection.size() == 0:
				return
			var zhanhouAnimation = PlayerAniamtion.ZhanHouChoose.new(collection)
			GameManager.get_main_scene().get_player_component().add_animation(
				zhanhouAnimation
			)
			var choosedMinion: Minion = await zhanhouAnimation.choice_made
			if is_instance_valid(choosedMinion):
				MinionUtils.liejie(choosedMinion)
			
class WenHeDeDengShen extends MinionZhanhouAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			var collection: MinionCollection = MinionCollection.new().add_collection(
				CardUtils.get_shopping_desk_card_collection().get_minion_collection()
			).erase(minion).filter_by(
				MinionCollection.Filter.new().set_race(Race.Type.YuanSu)
			).remove_unvaild().remove_father(minion)
			if collection == null or collection.size() < 2:
				return
			var zhanhouAnimation1 = PlayerAniamtion.ZhanHouChoose.new(collection)
			GameManager.get_main_scene().get_player_component().add_animation(
				zhanhouAnimation1
			)
			var choosedMinion1: Minion = await zhanhouAnimation1.choice_made
			if is_instance_valid(choosedMinion1):
				collection = collection.filter_by(
					MinionCollection.Filter.new().set_except_race(
						choosedMinion1.get_info().get_race() & ~Race.Type.YuanSu
					)
				).erase(choosedMinion1).remove_unvaild()
				var zhanhouAnimation2 = PlayerAniamtion.ZhanHouChoose.new(collection)
				GameManager.get_main_scene().get_player_component().add_animation(
					zhanhouAnimation2
				)
				var choosedMinion2: Minion = await zhanhouAnimation2.choice_made
				if is_instance_valid(choosedMinion2):
					MinionUtils.ronghe(choosedMinion1, choosedMinion2)

class NanHaiMaiYiZhe extends MinionZhanhouAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			DataManager.get_player_info().get_player_effect_collection().add_player_effect(
				Effect_RoundAddCoin.new(1)
			)

class WanShaLieTou extends MinionZhanhouAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"掠夺者合约"
						)
					).get_array().front()
				),
				minion.global_position,
				minion
			)

class BeiLeiShouCangJia extends MinionZhanhouAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"酒馆币"
						)
					).get_array().front()
				),
				minion.global_position,
				minion
			)

class QiShuKuangXiangJia extends MinionZhanhouAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			var magicInfo: MagicInfo = CardUtils.create_magic_info(
				DataManager.get_all_magic_data().filter_by(
					MagicDataCollection.Filter.new().set_name(
						"奇术狂想"
					)
				).get_array().front()
			)
			magicInfo.set_suzao(true)
			CardUtils.create_hand_card(
				magicInfo,
				minion.global_position,
				minion
			)
		
class ZhaoKanZheAoGeZuoYa extends MinionZhanhouAnimation:
	func play() -> void:
		for j in range(2 if minion.get_info().is_golden() else 1):
			var choice_data_array: Array[MinionData] = []
			for i in range(3):
				choice_data_array.append(
					DataManager.get_sellable_minion_data().filter_by(
						MinionDataCollection.Filter.new().set_race(
							Race.Type.NaJia
						).set_level_range(
							1,
							DataManager.get_shop_info().get_level()
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
					minion.global_position,
					minion
				)
		super.play()

class JingJiBiaoYanZhe extends MinionZhanhouAnimation:
	func play() -> void:
		for j in range(2 if minion.get_info().is_golden() else 1):
			var choice_data_array: Array[MagicData] = []
			for i in range(3):
				choice_data_array.append(
					DataManager.get_sellable_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_level_range(
							1,
							DataManager.get_shop_info().get_level()
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
					CardUtils.create_magic_info(choice_data_array[choosedIndex]),
					minion.global_position,
					minion
				)
		super.play()

class ZaiBianJuFengSiKaEr extends MinionZhanhouAnimation:
	func play() -> void:
		for j in range(2 if minion.get_info().is_golden() else 1):
			var choice_data_array: Array[Dictionary] = [
				{
					"name": "大地祈咒",
					"sprite_path": "res://assets/image/minion/fudai/大地祈咒.png",
					"description": "战斗开始时，使友方随从获得“亡语：召唤一个1/1的石元素"
				},
				{
					"name": "火焰祈咒",
					"sprite_path": "res://assets/image/minion/fudai/火焰祈咒.png",
					"description": "战斗开始时，使你最左边的随从攻击力翻倍"
				},
				{
					"name": "流水祈咒",
					"sprite_path": "res://assets/image/minion/fudai/流水祈咒.png",
					"description": "战斗开始时，使你最右边的随从获得+12生命值和嘲讽"
				},
				{
					"name": "闪电祈咒",
					"sprite_path": "res://assets/image/minion/fudai/闪电祈咒.png",
					"description": "战斗开始时，随机对3个敌方随从造成3点伤害"
				}
			]
			var faxianAnimation = PlayerAniamtion.FaXianChoose.new(choice_data_array)
			GameManager.get_main_scene().get_player_component().add_animation(
				faxianAnimation
			)
			var choosedIndex: int = await faxianAnimation.choice_made
			match choosedIndex:
				0:
					DataManager.get_player_info().get_player_effect_collection().add_player_effect(
						Effect_DaDiQiZhou.new()
					)
				1:
					DataManager.get_player_info().get_player_effect_collection().add_player_effect(
						Effect_HuoYanQiZhou.new()
					)
				2:
					DataManager.get_player_info().get_player_effect_collection().add_player_effect(
						Effect_LiuShuiQiZhou.new()
					)
				3:
					DataManager.get_player_info().get_player_effect_collection().add_player_effect(
						Effect_ShanDianQiZhou.new()
					)
		super.play()
