### 进击
extends MinionAnimation
class_name MinionAttackBeforeMinionAnimation

var attackMinion: Minion = null
var behitMinion: Minion = null
var minion: Minion = null
func _init(_attackMinion: Minion, _behitMinion: Minion, _minion: Minion) -> void:
	attackMinion = _attackMinion
	behitMinion = _behitMinion
	minion = _minion
func play() -> void:
		pass
	
class SiXinLangDuiZhang extends MinionAttackBeforeMinionAnimation:
	func play() -> void:
		MinionUtils.add_stats(
			minion,
			attackMinion,
			Stats.new(6, 0) if minion.get_info().is_golden() else Stats.new(3, 0)
		)

class WangLingJianZhangYiLiZha extends MinionAttackBeforeMinionAnimation:
	func play() -> void:
		var effect: PlayerEffect = CardUtils.get_belong_player_effect(minion).find_effect(
			Effect_LastAttacker
		)
		if effect != null:
			if minion.get_info().is_player():
				if (effect as Effect_LastAttacker).is_player():
					minion.get_info().get_boost_counter_info().add_count(1)
			elif minion.get_info().is_enemy():
				if (effect as Effect_LastAttacker).is_enemy():
					minion.get_info().get_boost_counter_info().add_count(1)
		var attack: int = (minion.get_info().get_boost_counter_info().get_count()+1)*(4 if minion.get_info().is_golden() else 2)
		CardUtils.get_belong_player_effect(minion).add_player_effect(
			Effect_FightMinionAttack.new(attack)
		)
		for _minion in CardUtils.get_belong_card_collection(minion).get_array():
			MinionUtils.add_stats(minion, _minion, Stats.new(attack, 0))
