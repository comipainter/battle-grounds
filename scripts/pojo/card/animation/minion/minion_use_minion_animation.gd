# 使用随从
extends MinionAnimation
class_name MinionUseMinionAnimation

var usedMinion: Minion = null
var minion: Minion = null
func _init(_usedMinion: Minion, _minion: Minion) -> void:
	usedMinion = _usedMinion
	minion = _minion
func play() -> void:
		pass

class PaiDuiYuanSu extends MinionUseMinionAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			if MinionUtils.is_race(
				usedMinion.get_info().get_race(),
				Race.Type.YuanSu
			):
				var leftestMinion: Minion = CardUtils.get_shopping_desk_card_collection()\
				.get_minion_collection().sort_by_position().get_array().get(0)
				if is_instance_valid(leftestMinion):
					push_warning("leftest minion not found")
				for i in range(2 if minion.get_info().is_golden() else 1):
					MinionUtils.add_stats(minion, leftestMinion, Stats.new(1, 2))

class KuangFangDeFaLiYongLiu extends MinionUseMinionAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			if MinionUtils.is_race(
				usedMinion.get_info().get_race(),
				Race.Type.YuanSu
			):
				for _minion: Minion in CardUtils.get_shopping_desk_card_collection().get_minion_collection().filter_by(
					MinionCollection.Filter.new().set_race(Race.Type.YuanSu)
				).get_array():
					for i in range(2 if minion.get_info().is_golden() else 1):
						_minion.get_info().add_stats(Stats.new(1, 1))

class ShouHuZheAiKuLong extends MinionUseMinionAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			if MinionUtils.is_race(
				usedMinion.get_info().get_race(),
				Race.Type.YuanSu
			):
				if minion.get_info().is_golden():
					usedMinion.get_info().get_keyword_info().set_shengdun(true)
				else:
					usedMinion.get_info().get_effect_collection().add_minion_effect(
						MinionEffect_RoundShengdun.new(usedMinion.get_info())
					)
		
class QiEnWaLa extends MinionUseMinionAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			if MinionUtils.is_race(
				usedMinion.get_info().get_race(),
				Race.Type.YuanSu
			):
				minion.get_info().get_counter_info().add_count(1)

class SuiDiZhe extends MinionUseMinionAnimation:
	func play() -> void:
		if DataManager.get_game_info().is_shopping():
			if MinionUtils.is_race(
				usedMinion.get_info().get_race(),
				Race.Type.NaJia
			):
				MinionUtils.add_stats(
					minion,minion,
					StatsUtils.mul_stats(
						Stats.new(8,8) if minion.get_info().is_golden() else Stats.new(4,4),
						CardUtils.get_belong_player_effect(minion).find_effect(
							Effect_UseMagic
						).get_value()/3+1
					)
				)
