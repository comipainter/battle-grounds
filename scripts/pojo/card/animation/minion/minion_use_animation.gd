### 回合结束
extends MinionAnimation
class_name MinionUseAnimation

var minion: Minion = null
func _init(_minion: Minion) -> void:
	minion = _minion

func play() -> void:
	pass

class SanLian extends MinionUseAnimation:
	func play() -> void:
		CardUtils.create_hand_card(
			CardUtils.create_magic_info(
				DataManager.get_all_magic_data().filter_by(
					MagicDataCollection.Filter.new().set_name(
						"三连奖励"
					)
				).get_array().front()
			),
			minion.global_position,
			minion
		)
		

class QiEnWaLa extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			5,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#if DataManager.get_game_info().is_shopping():
					#for i in range(2 if _minion.get_info().is_golden() else 1):
						#CardUtils.create_hand_card(
							#CardUtils.create_minion_info(
								#DataManager.get_all_minion_data().filter_by(
									#MinionDataCollection.Filter.new().set_race(
										#Race.Type.YuanSu
									#).set_level_range(
										#1, 
										#DataManager.get_shop_info().get_level()
									#)
								#).pick_random()
							#),
							#_minion.global_position,
							#_minion
						#)
				#)
		)

class YongRanHuoFeng extends MinionUseAnimation:
	func play() -> void:
		if minion.get_info().get_counter_info().is_able() == false:
			minion.get_info().get_counter_info().create_count(
				0,
				10,
				"container",
				minion.get_info().get_card_name()
				#MinionCounterFunction.new(func():pass)
			)

class ShiTiTiLianShi extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			4,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#DataManager.get_player_info().get_player_effect_collection().add_player_effect(
					#Effect_RoundAddCoin.new(2 if _minion.get_info().is_golden() else 1)
				#)
				#)
		)

class JinBiZhaPianFan extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			6,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#DataManager.get_shop_info().set_coin_limit(
					#DataManager.get_shop_info().get_coin_limit()+(2 if _minion.get_info().is_golden() else 1)
				#)
				#_minion.get_info().get_boost_counter_info().add_count(1)
				#)
		)
		minion.get_info().get_boost_counter_info().create(0)

class ZhouFuHaiYuan extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			3,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#for i in range(2 if _minion.get_info().is_golden() else 1):
					#CardUtils.create_hand_card(
						#CardUtils.create_magic_info(
							#DataManager.get_sellable_magic_data().filter_by(
								#MagicDataCollection.Filter.new().set_level_range(
									#1,
									#DataManager.get_shop_info().get_level()
								#)
							#).pick_random()
						#),
						#_minion.global_position,
						#_minion
					#)
				#)
		)

class WangLingJianZhangYiLiZha extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_boost_counter_info().create(0)

class HaiLangTiDaoHao extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_boost_counter_info().create(8 if minion.get_info().is_golden() else 4)
		minion.get_info().get_counter_info().create_count(
			0,
			4,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#if _minion.get_info().get_boost_counter_info().get_count() > 0:
					#_minion.get_info().get_boost_counter_info().add_count(-1)
					#CardUtils.create_desk_card(
						#CardUtils.create_minion_info(
							#DataManager.get_all_minion_data().filter_by(
								#MinionDataCollection.Filter.new().set_name(
									#"海盗无赖"
								#)
							#).pick_random()
						#),
						#_minion.global_position,
						#_minion,
						#func(_card: Card):
							#(_card as Minion).add_animation(
								#MinionAnimation.AttackStartAnimation.new(
									#_card,
									#CardUtils.get_opponent_card_collection(_card).get_minion_collection().get_behit_minion()
								#)
							#)
					#)
				#)
		)
		
class HuangJinKuangChaoQiSheXieYi extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_click_info().create(
			true,
			"res://assets/image/minion/minion_scene/click.png",
			Vector2(0.438, 0.438),
			Vector2(-80, -96),
			null,
			MinionClickFunction.new(func(_minion: Minion, mouse_position: Vector2):
				if ShapeUtils.is_point_in_rect(mouse_position, Vector2(-112, -128), Vector2(-48, -64)):
					return "hit"
				return "unhit"
				),
			MinionHitFunction.new(func(_minion: Minion, mouse_position: Vector2):
				if DataManager.get_game_info().is_shopping():
					if DataManager.get_shop_info().get_coin() >=5 :
						DataManager.get_shop_info().sub_coin(5)
						_minion.get_info().get_boost_counter_info().add_count(1)
						var stats: Stats = StatsUtils.mul_stats(
							Stats.new(10,10) if _minion.get_info().is_golden() else Stats.new(5,5),
							_minion.get_info().get_boost_counter_info().get_count()
						)
						for __minion in CardUtils.get_belong_card_collection(_minion).get_minion_collection().get_array():
							MinionUtils.add_stats(_minion, __minion, stats)
				)
		)
		minion.get_info().get_boost_counter_info().create(
			0
		)

class HaiShangShuangXiong extends MinionUseAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"海潮的祝福"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class ZaShuaQiShuShi extends MinionUseAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"奇术杂耍"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class ReQingShaChuiShou extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			2 if minion.get_info().is_golden() else 1,
			"container",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func():pass)
		)

class ChengBoQishi extends MinionUseAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"骑士的祝福"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class GuShenDeWeiShi extends MinionUseAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"古神的祝福"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class HuaDaoHuaXingZhe extends MinionUseAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"滑道滑行术"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)

class AnChaoZhanLueZhuanJia extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_boost_counter_info().create(1)
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"暗流涌动"
						)
					).pick_random()
				),
				minion.global_position,
				minion,
				func(card: Card):
					(card as Magic).get_info().get_boost_counter_info().create(
						1
					)
			)

class XiLiWaZi extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			2 if minion.get_info().is_golden() else 1,
			"container",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func():pass)
		)

class DaChuNuoMi extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,	
			3,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#DataManager.get_player_info().set_hand_card_num(
					#DataManager.get_player_info().get_hand_card_num()+(2 if _minion.get_info().is_golden() else 1)
				#)
				#)
		)

class YiXinDiAoSi extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			4,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				#if DataManager.get_game_info().is_fighting():
					#var _collection = CardUtils.get_opponent_card_collection(_minion).get_minion_collection().pick_random_collection(
						#2,
						#false
					#)
					#if _collection.size() == 0:
						#return
					#if _collection.size() >= 1:
						#_collection.get_array().front().get_info().take_damage(
							#_minion.get_info().get_stats().get_attack()*(2 if _minion.get_info().is_golden() else 1)
						#)
						#if _collection.size() == 2:
							#_collection.get_array().get(1).get_info().take_damage(
								#_minion.get_info().get_stats().get_attack()*(2 if _minion.get_info().is_golden() else 1)
							#)
				#)
		)

class FengBaoFenLiuZhe extends MinionUseAnimation:
	signal magic_deleted
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			6,
			"normal",
			minion.get_info().get_card_name()
			#MinionCounterFunction.new(func(_minion: Minion):
				## 创建法术
				#for i in range(2 if _minion.get_info().is_golden() else 1):
					#if DataManager.get_shop_info().get_hand_info_collection().size() < DataManager.get_player_info().get_hand_card_num():
						#CardUtils.create_free_card(
							#CardUtils.create_magic_info(
								#DataManager.get_all_magic_data().filter_by(
									#MagicDataCollection.Filter.new().set_name(
										#"娜迦归潮"
									#)
								#).get_array().front()
							#),
							#_minion.global_position,
							#_minion,
							#func(_card: Card):
								#(_card as Magic).deleted.connect(magic_deleted.emit)
								#_card.add_animation(AnimationManager._magic_match(
									#_card.get_info().get_card_name(),
									#MagicAnimationDefinition.Type.AUTO_USE,
									#[_card]
								#))
						#)
						#await magic_deleted
				#)
		)

class NaiXinDeZhenChaYuan extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			1,
			6,
			"container",
			minion.get_info().get_card_name()
		)

class KongJunShangJiangLuoJieSi extends MinionUseAnimation:
	func play() -> void:
		minion.get_info().get_counter_info().create_count(
			0,
			10,
			"normal",
			minion.get_info().get_card_name()
		)

class JinQiangGeLeiTa extends MinionUseAnimation:
	func play() -> void:
		for i in range(2 if minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"金色大衍术"
						)
					).pick_random()
				),
				minion.global_position,
				minion
			)
