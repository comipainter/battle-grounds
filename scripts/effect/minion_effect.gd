class_name MinionEffect

var name: String
var description: String
var spritePath: String

func duplicate() -> MinionEffect:
	var copy: MinionEffect = MinionEffect.new()
	copy.name = name
	copy.description = description
	copy.spritePath = spritePath
	return copy

func combine(effect: MinionEffect):
	pass

func use(minion: Minion):
	pass

func round_start(minion: Minion):
	pass

class RoundShengdun extends MinionEffect:
	var originShengdun: bool
	func _init(spritePath: String) -> void:
		self.name = "直到下个回合的圣盾"
		self.description = "直到下个回合开始时，使该随从获得圣盾"
		self.spritePath = spritePath
	func duplicate() -> MinionEffect.RoundShengdun:
		var copy: MinionEffect.RoundShengdun = super.duplicate()
		copy.originShengdun = originShengdun
		return copy
	func combine(effect: MinionEffect) -> bool:
		if effect.name == self.name:
			return true
		return false
	func use(minion: Minion) -> void:
		originShengdun = minion.is_shengdun()
		minion.set_shengdu(true)
	func round_start(minion: Minion) -> bool:
		minion.set_shengdu(originShengdun)
		return true
