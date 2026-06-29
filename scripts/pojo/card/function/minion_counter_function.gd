extends Resource
class_name MinionCounterFunction

static func activate(minion: Minion, function: Callable) -> void:
	if function.is_null():
		push_error("MinionCounterFunction: function is null, skipping call.")
		return
	if function.get_argument_count() > 0:
		function.call(minion)
	else:
		function.call()

@export var match_name : String

func get_match_name() -> String:
	return match_name

class QiEnWaLa extends MinionCounterFunction:
	static func run(_minion: Minion):
		if DataManager.get_game_info().is_shopping():
			for i in range(2 if _minion.get_info().is_golden() else 1):
				CardUtils.create_hand_card(
					CardUtils.create_minion_info(
						DataManager.get_sellable_minion_data().filter_by(
							MinionDataCollection.Filter.new().set_race(
								Race.Type.YuanSu
							).set_level_range(
								1, 
								DataManager.get_shop_info().get_level()
							)
						).pick_random()
					),
					_minion.global_position,
					_minion
				)

class YongRanHuoFeng extends MinionCounterFunction:
	static func run():
		pass

class ShiTiTiLianShi extends MinionCounterFunction:
	static func run(_minion: Minion):
		DataManager.get_player_info().get_player_effect_collection().add_player_effect(
			Effect_RoundAddCoin.new(2 if _minion.get_info().is_golden() else 1)
		)

class JinBiZhaPianFan extends MinionCounterFunction:
	static func run(_minion: Minion):
		DataManager.get_shop_info().set_coin_limit(
			DataManager.get_shop_info().get_coin_limit()+(2 if _minion.get_info().is_golden() else 1)
		)
		_minion.get_info().get_boost_counter_info().add_count(1)
				
class ZhouFuHaiYuan extends MinionCounterFunction:
	static func run(_minion: Minion):
		for i in range(2 if _minion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_sellable_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_level_range(
							1,
							DataManager.get_shop_info().get_level()
						)
					).pick_random()
				),
				_minion.global_position,
				_minion
			)

class HaiLangTiDaoHao extends MinionCounterFunction:
	static func run(_minion: Minion):
		if _minion.get_info().get_boost_counter_info().get_count() > 0:
			_minion.get_info().get_boost_counter_info().add_count(-1)
			CardUtils.create_desk_card(
				CardUtils.create_minion_info(
					DataManager.get_all_minion_data().filter_by(
						MinionDataCollection.Filter.new().set_name(
							"海盗无赖"
						)
					).pick_random()
				),
				_minion.global_position,
				_minion,
				func(_card: Card):
					(_card as Minion).add_animation(
						MinionAnimation.AttackStartAnimation.new(
							_card,
							CardUtils.get_opponent_card_collection(_card).get_minion_collection().get_behit_minion()
						)
					)
			)
		
class ReQingShaChuiShou extends MinionCounterFunction:
	static func run(_minion: Minion):
		pass

class XiLiWaZi extends MinionCounterFunction:
	static func run(_minion: Minion):
		pass
		
class YiXinDiAoSi extends MinionCounterFunction:
	static func run(_minion: Minion):
		if DataManager.get_game_info().is_fighting():
			var _collection = CardUtils.get_opponent_card_collection(_minion).get_minion_collection().pick_random_collection(
				2,
				false
			)
			if _collection.size() == 0:
				return
			if _collection.size() >= 1:
				_collection.get_array().front().get_info().take_damage(
					_minion.get_info().get_stats().get_attack()*(2 if _minion.get_info().is_golden() else 1)
				)
				if _collection.size() == 2:
					_collection.get_array().get(1).get_info().take_damage(
						_minion.get_info().get_stats().get_attack()*(2 if _minion.get_info().is_golden() else 1)
					)

class FengBaoFenLiuZhe extends MinionCounterFunction:
	static func run(_minion: Minion):
		# 创建法术
		for i in range(2 if _minion.get_info().is_golden() else 1):
			if DataManager.get_shop_info().get_hand_info_collection().size() < DataManager.get_player_info().get_hand_card_num():
				var state = {"card": null} 
				CardUtils.create_free_card(
					CardUtils.create_magic_info(
						DataManager.get_all_magic_data().filter_by(
							MagicDataCollection.Filter.new().set_name(
								"娜迦归潮"
							)
						).get_array().front()
					),
					_minion.global_position,
					_minion,
					func(_card: Card):
						state["card"] = _card
						_card.add_animation(AnimationManager._magic_match(
							_card.get_info().get_card_name(),
							MagicAnimationDefinition.Type.AUTO_USE,
							[_card]
						))
				)
				if is_instance_valid(state["card"]):
					await state["card"].deleted

class NaiXinDeZhenChaYuan extends MinionCounterFunction:
	static func run():
		pass

class KongJunShangJiangLuoJieSi extends MinionCounterFunction:
	static func run(_minion: Minion):
		# 创建法术
		for i in range(2 if _minion.get_info().is_golden() else 1):
			# 随机生成一个悬赏令
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_sellable_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_contain_name(
							"悬赏令"
						)
					).pick_random()
				),
				_minion.global_position,
				_minion
			)
