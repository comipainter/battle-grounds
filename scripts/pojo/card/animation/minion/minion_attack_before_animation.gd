### 进击
extends MinionAnimation
class_name MinionAttackBeforeAnimation

var attackMinion: Minion = null
var behitMinion: Minion = null
func _init(_attackMinion: Minion, _behitMinion: Minion) -> void:
	attackMinion = _attackMinion
	behitMinion = _behitMinion
func play() -> void:
		pass
	
class BaoLieJuFeng extends MinionAttackBeforeAnimation:
	func play() -> void:
		var original_scale = attackMinion.scale  # 保存原始缩放
		var enlarged_scale = original_scale * 1.2  # 放大 1.5 倍
		var tween1 = attackMinion.create_tween()
		tween1.tween_property(attackMinion, "scale", enlarged_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween1.tween_property(attackMinion, "modulate:a", 0.7, 0.2).set_ease(Tween.EASE_OUT)
		await tween1.finished
		
		# 开始数值计算
		for i in range(2 if attackMinion.get_info().is_golden() else 1):
			MinionUtils.add_stats(
				attackMinion, 
				attackMinion, 
				Stats.new(1, 0), 
				true
			)
		
		var tween2 = attackMinion.create_tween()
		tween2.tween_property(attackMinion, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		tween2.tween_property(attackMinion, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_IN)
		await tween2.finished

class DaoJianShouCangJia extends MinionAttackBeforeAnimation:
	func play() -> void:
		var adjacentMinion: MinionCollection = CardUtils.get_opponent_card_collection(
			attackMinion
		).get_minion_collection().get_adjacent_minions(
			behitMinion
		)
		if adjacentMinion.size() >= 1:
			adjacentMinion.get_array().get(0).get_info().take_damage(
				attackMinion.get_info().get_stats().get_attack()
			)
		if adjacentMinion.size() >= 2:
			adjacentMinion.get_array().get(1).get_info().take_damage(
				attackMinion.get_info().get_stats().get_attack()
			)

class HaiChuangZhaoMuZhe extends MinionAttackBeforeAnimation:
	signal played 
	func play() -> void:
		for i in range(2 if attackMinion.get_info().is_golden() else 1):
			CardUtils.create_hand_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"深沉蓝调"
						)
					).pick_random()
				),
				attackMinion.global_position,
				attackMinion
			)
			CardUtils.create_free_card(
				CardUtils.create_magic_info(
					DataManager.get_all_magic_data().filter_by(
						MagicDataCollection.Filter.new().set_name(
							"深沉蓝调"
						)
					).pick_random()
				),
				attackMinion.global_position,
				attackMinion,
				func(_card: Card):
					var magic_animation = MagicPointedUseAnimation.ShenChenLanDiao.new(_card, attackMinion)
					(_card as Magic).deleted.connect(
						played.emit
					)
					(_card as Magic).add_animation(magic_animation)
			)
			await played

class AoShuHuoPaoShou extends MinionAttackBeforeAnimation:
	func play() -> void:
		behitMinion.get_info().take_damage(
			CardUtils.get_belong_player_effect(attackMinion).find_effect(
				Effect_RoundUseMagic
			).get_value()*(4 if attackMinion.get_info().is_golden() else 2)
		)
