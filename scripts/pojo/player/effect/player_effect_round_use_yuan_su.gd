extends PlayerEffect
class_name Effect_RoundUseYuanSu 
func _init() -> void:
	self.effect_name = "本回合已使用元素"
	self.value = 0
	self.sprite_path = "res://assets/image/minion/溢流熔岩.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		return
	elif self.effect_name == _effect.effect_name:
		_delete(_effect)
func _on_round_started() -> void:
	self.value = 0
func _on_used_minion(minion: Minion) -> void:
	if MinionUtils.is_race(
		minion.get_info().get_race(),
		Race.Type.YuanSu
	):
		self.value += 1
func get_description() -> String:
	return effect_name + "： " + str(value) + "个"
