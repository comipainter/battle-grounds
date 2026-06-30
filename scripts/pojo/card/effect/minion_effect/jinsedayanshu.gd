class_name MinionEffect_JinSeDaYanShu extends MinionEffect

@export var originGolden: bool = false
@export var info: MinionInfo = MinionInfo.new()
@export var time_limit: float = 30
@export var curr_time: float = 0
func _init(_info: MinionInfo = MinionInfo.new()) -> void:
	self.info = _info
	self.originGolden = _info.is_golden()
	self.effect_name = "变为金色，定时（30）：移除本效果"
	self.sprite_path = "res://assets/image/magic/金色大衍术.png"
func _on_minion_effect_added(_effect: MinionEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		MinionUtils.set_golden(info)
	elif self.effect_name == _effect.effect_name:
		_delete(_effect)
func _on_processed(minion: Minion, delta: float) -> void:
	if minion.get_info().is_shopping_desk():
		curr_time += delta
		if curr_time >= time_limit:
			MinionUtils.set_golden_by_bool(
				minion.get_info(),
				self.originGolden
			)
			_delete(self)
