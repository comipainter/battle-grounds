extends BaseAnimation
class_name MinionAnimation

class AttackStartAnimation extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(_attackMinion: Minion, _behitMinion: Minion):
		self.attackMinion = _attackMinion
		self.behitMinion = _behitMinion
	func play() -> void:
		# 检查攻击方和受击方是否存在和存活
		if MinionUtils.is_alive(attackMinion) == false:
			return
		if MinionUtils.is_alive(behitMinion) == false:
			# 如果受击方死亡或不存在则更换目标
			behitMinion = CardUtils.get_opponent_card_collection(attackMinion).get_minion_collection().get_behit_minion()
			if behitMinion == null: # 如果已经没有可攻击随从
				attackMinion.get_move_component().enable_follow()
				return
			
		print(attackMinion.get_info().get_card_name() + "： 执行攻击前后撤动画")
		attackMinion.get_move_component().disable_follow()
		var tween = attackMinion.create_tween()
		var backOffset = (behitMinion.global_position - attackMinion.global_position).normalized() * 40
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(attackMinion, "global_position", attackMinion.global_position - backOffset, 0.5)
		await tween.finished
		
		# 检查攻击方和受击方是否存在和存活
		if MinionUtils.is_alive(attackMinion) == false:
			return
		if MinionUtils.is_alive(behitMinion) == false:
			# 如果受击方死亡或不存在则更换目标
			behitMinion = CardUtils.get_opponent_card_collection(attackMinion).get_minion_collection().get_behit_minion()
			if behitMinion == null: # 如果已经没有可攻击随从
				attackMinion.get_move_component().enable_follow()
				return
			
		## 触发进击动画
		attackMinion.attack_befored.emit(attackMinion, behitMinion)
		# 触发攻击动画
		attackMinion.add_animation(MinionAnimation.AttackIngAnimation.new(attackMinion, behitMinion))

class AttackIngAnimation extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(_attackMinion: Minion, _behitMinion: Minion):
		self.attackMinion = _attackMinion
		self.behitMinion = _behitMinion
	func play() -> void:
		# 检查攻击方和受击方是否存在和存活
		if MinionUtils.is_alive(attackMinion) == false:
			return
		if MinionUtils.is_alive(behitMinion) == false:
			# 如果受击方死亡或不存在则更换目标
			behitMinion = CardUtils.get_opponent_card_collection(attackMinion).get_minion_collection().get_behit_minion()
			if behitMinion == null: # 如果已经没有可攻击随从
				attackMinion.get_move_component().enable_follow()
				return
			
		print(attackMinion.get_info().get_card_name() + "： 执行攻击动画")
		var tween = attackMinion.create_tween()
	
		var original_pos = attackMinion.global_position
		var direction = (behitMinion.global_position - original_pos).normalized()
		var attack_offset = direction * 50

		# 蓄力后向前突进
		tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(attackMinion, "global_position", behitMinion.global_position - attack_offset,0.2)

		# 短暂停顿
		tween.tween_callback(
			func():
				# 检查攻击方和受击方是否存在和存活
				if MinionUtils.is_alive(behitMinion) == false:
					# 结束动画
					attackMinion.get_move_component().enable_follow()
					return
				if MinionUtils.is_alive(attackMinion) == false:
					return
				## 触发攻击时动画判断
				attackMinion.attack_inged.emit(attackMinion, behitMinion)
				# 添加攻击返回动画
				attackMinion.add_animation(MinionAnimation.AttackEndAnimation.new(attackMinion, behitMinion))
		)
		await tween.finished
		
class AttackEndAnimation extends MinionAnimation:
	var attackMinion: Minion
	var behitMinion: Minion
	func _init(_attackMinion: Minion, _behitMinion: Minion):
		self.attackMinion = _attackMinion
		self.behitMinion = _behitMinion
	func play() -> void:
		# 检查攻击方和受击方是否存在和存活
		if MinionUtils.is_alive(behitMinion) == false:
			# 结束动画
			attackMinion.get_move_component().enable_follow()
			return
		if MinionUtils.is_alive(attackMinion) == false:
			return
			
		print(attackMinion.get_info().get_card_name() + "： 执行攻击后返回动画")
		var tween = attackMinion.create_tween()
		# 加速回到原位
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(
			attackMinion, 
			"global_position", 
			attackMinion.get_move_component().get_target().global_position, 0.5)
		await tween.finished
		
		# 检查攻击方和受击方是否存在和存活
		if MinionUtils.is_alive(behitMinion) == false:
			# 结束动画
			attackMinion.get_move_component().enable_follow()
			return
		if MinionUtils.is_alive(attackMinion) == false:
			return
		
		## 触发攻击后判定逻辑
		attackMinion.attack_aftered.emit(attackMinion, behitMinion)
		
		# 开始跟随
		attackMinion.get_move_component().enable_follow()
		
		# 触发双方属性扣减动画
		# 完成攻击后再扣减使得双方随从能同时死亡
		attackMinion.get_info().take_damage(
			behitMinion.get_info().get_stats().get_attack()
		)
		behitMinion.get_info().take_damage(
			attackMinion.get_info().get_stats().get_attack()
		)
		
		#if attackMinion.get_info().get_keyword_info().is_fengnu():
			#behitMinion = CardUtils.get_opponent_card_collection(attackMinion).get_minion_collection().get_behit_minion()
			#if behitMinion != null:
				#attackMinion.add_animation(MinionAnimation.AttackStartAnimation.new(attackMinion, behitMinion))

class DieAnimation extends MinionAnimation:
	var minion: Minion
	func _init(_minion: Minion):
		self.minion = _minion
	func play() -> void:
		print(minion.get_info().get_card_name() + "： 执行死亡动画")
		var tween = minion.create_tween()
		tween.tween_property(minion, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(minion, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
		await tween.finished
		CardUtils.remove_card(minion)
		# 发出亡语信号
		minion.dead_after.emit(minion)
		minion.add_animation(MinionAnimation.DeleteAnimation.new(minion))

class DeleteAnimation extends MinionAnimation:
	var minion: Minion
	func _init(_minion: Minion):
		self.minion = _minion
	func play() -> void:
		print(minion.get_info().get_card_name() + "： 执行移除动画")
		CardUtils.delete_card(minion)

class SoldAnimation extends MinionAnimation:
	var minion: Minion
	func _init(_minion: Minion):
		self.minion = _minion
	func play() -> void:
		print(minion.get_info().get_card_name() + "： 执行售出动画")
		if DataManager.get_game_info().is_shopping():
			if is_instance_valid(GameManager.mainScene):
				DataManager.get_shop_info().remove_card_info(minion.get_info())
				minion.sold.emit(minion)
				minion.add_animation(MinionAnimation.DeleteAnimation.new(minion))

class BeTripleAnimation extends MinionAnimation:
	var minion: Minion
	func _init(minion: Minion):
		self.minion = minion
	func play() -> void:
		print(minion.get_info().get_card_name() + "： 执行被三连动画")
		minion.get_move_component().disable_follow()
		minion.get_move_component().disable_drag()
		var tween = minion.create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(minion, "scale", Vector2.ZERO, 1.5)
		tween.tween_property(minion, "modulate:a", 0.0, 1.5)
		tween.tween_property(minion, "global_position", Vector2(1280, 720), 1.5)
		tween.tween_callback(
			func():
				CardUtils.remove_card(minion)
				minion.add_animation(MinionAnimation.DeleteAnimation.new(minion))
		)
		await tween.finished

class XifuAnimation extends MinionAnimation:
	var ciliMinion: Minion
	var beXifuMinion: Minion
	func _init(_ciliMinion: Minion, _beXifuMinion: Minion):
		self.ciliMinion = _ciliMinion
		self.beXifuMinion = _beXifuMinion
	func play() -> void:
		print(ciliMinion.get_info().get_card_name() + "： 执行吸附动画, 吸附随从： " + beXifuMinion.get_info().get_card_name())
		
		# 检查双方随从是否存在和存活
		if MinionUtils.is_alive(ciliMinion) == false:
			return
		if MinionUtils.is_alive(beXifuMinion) == false:
			return

		ciliMinion.get_move_component().disable_follow()
		ciliMinion.get_move_component().disable_drag()
		
		#minion.z_index = -1
		
		var tween = ciliMinion.create_tween()
		# 阶段1：缩小到0.6倍（0.3秒）
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(ciliMinion, "scale", Vector2(0.6, 0.6), 0.3)
		# 阶段2：移动到目标随从的全局位置（0.4秒）
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(ciliMinion, "global_position", beXifuMinion.global_position, 0.4)
		tween.tween_callback(
			func():
				CardUtils.remove_card(ciliMinion)
				MinionUtils.xifu(ciliMinion, beXifuMinion)
				ciliMinion.add_animation(MinionAnimation.DeleteAnimation.new(ciliMinion))
		)
		await tween.finished
