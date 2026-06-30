class_name MinionEffect_RoundShengdun extends MinionEffect

@export var originShendun: bool = false
@export var info: MinionInfo = MinionInfo.new()
func _init(_info: MinionInfo = MinionInfo.new()) -> void:
	self.effect_name = "直到下回合拥有圣盾"
	self.info = _info
	self.originShendun = _info.get_keyword_info().is_shengdun()
	self.sprite_path = "res://assets/image/minion/守护者艾库隆.png"
func get_description() -> String:
	return effect_name
func _on_minion_effect_added(_effect: MinionEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		info.get_keyword_info().set_shengdun(true)
	elif self.effect_name == _effect.effect_name:
		_delete(_effect)
func _on_round_started(minion: Minion) -> void:
	# 回到原始状态
	minion.get_info().get_keyword_info().set_shengdun(
		self.originShendun
	)
	# 解除绑定
	_delete(self)
