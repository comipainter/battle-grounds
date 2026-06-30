class_name MinionEffect_QiShuZaShuai extends MinionEffect

@export var stats: Stats = Stats.new(0,0)
@export var info: MinionInfo = MinionInfo.new()
func _init(_stats: Stats = Stats.new(0,0), _info: MinionInfo = MinionInfo.new()) -> void:
	self.effect_name = "直到下回合获得属性"
	self.stats = _stats
	self.info = _info
	self.sprite_path = "res://assets/image/minion/杂耍奇术师.png"
func get_description() -> String:
	return effect_name + str(": ") + str(stats.get_attack()) + "/" + str(stats.get_health())
func _on_minion_effect_added(_effect: MinionEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		info.add_stats(self.stats)
func _on_round_started(_minion: Minion) -> void:
	var presub_stats = StatsUtils.sub_stats(_minion.get_info().get_stats(), stats)
	if presub_stats.get_health() <= 0 or presub_stats.get_attack() < 0:
		_minion.get_info().set_stats(Stats.new(1, 1))
	else:
		_minion.get_info().sub_stats(stats)
	# 解除绑定
	_delete(self)
