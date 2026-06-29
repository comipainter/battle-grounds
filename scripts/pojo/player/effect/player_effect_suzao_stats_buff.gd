class_name Effect_SuZaoStatsBuff extends PlayerEffect
@export var stats: Stats = Stats.new(0,0)
func _init(_stats: Stats = Stats.new(0,0)) -> void:
	self.effect_name = "本局能使随从获得属性值的塑造法术在本局对战中使随从额外获得"
	self.stats = _stats
	self.sprite_path = "res://assets/image/minion/柔心海妖.png"
func _on_player_effect_added(_effect: PlayerEffect) -> void:
	if self == _effect:  # 则说明自己被加入
		pass
	elif self.effect_name == _effect.effect_name:
		self.stats.add_stats((_effect as Effect_SuZaoStatsBuff).get_stats())
		_delete(_effect)
func get_stats() -> Stats:
	return self.stats
func get_description() -> String:
	return effect_name + str(": ") + str(stats.get_attack()) + "/" + str(stats.get_health())
