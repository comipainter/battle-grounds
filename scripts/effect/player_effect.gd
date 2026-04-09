class_name PlayerEffect

var name: String
var value: int = 0
var spritePath: String = ""

func round_start() -> void:
	pass
func get_value() -> int:
	return value
func add_value(num: int) -> void:
	value += num

func description() -> String:
	return name + str(": ") + str(value)
func combine(effect: PlayerEffect) -> bool:
	return false
func check() -> bool:
	return false
func execute():
	pass
	
class GeLeiSiFaXiEr1 extends PlayerEffect:
	var restRounds: int = 1
	func _init(value: int) -> void:
		self.name = "下回合开始时额外获得铸币"
		self.value = value
		self.spritePath = "res://assets/image/minion/格蕾丝法希尔.png"
	func combine(effect: PlayerEffect) -> bool:
		if self.name == effect.name:
			self.value += effect.value
			return true
		return false
	func round_start() -> void:
		restRounds -= 1
		if restRounds == 0:
			GameManager.shopScene.add_coin(self.value)
			GameManager.playerEffectList.remove_effect(self)
			
class GeLeiSiFaXiEr2 extends PlayerEffect:
	var restRounds: int = 2
	func _init(value: int) -> void:
		self.name = "下下回合开始时额外获得铸币"
		self.value = value
		self.spritePath = "res://assets/image/minion/格蕾丝法希尔.png"
	func combine(effect: PlayerEffect) -> bool:
		if self.name == effect.name:
			self.value += effect.value
			return true
		return false
	func round_start() -> void:
		restRounds -= 1
		if restRounds == 0:
			GameManager.shopScene.add_coin(self.value)
			GameManager.playerEffectList.remove_effect(self)
	
class FreeFresh extends PlayerEffect:
	func _init(value: int) -> void:
		self.name = "免费刷新"
		self.value = value
		self.spritePath = "res://assets/image/minion/刷新畸体.png"
	func combine(effect: PlayerEffect) -> bool:
		if self.name == effect.name:
			self.value += effect.value
			return true
		return false
	func check() -> bool:
		return self.value > 0
	func execute() -> void:
		if self.value > 0:
			self.value -= 1

class MoreFresh extends PlayerEffect:
	var function: Callable
	func _init(value: int, function: Callable) -> void:
		self.name = "刷新后提供额外的随从"
		self.value = value
		self.function = function
		self.spritePath = "res://assets/image/minion/刷新畸体.png"
	func execute() -> Array[CardInfo]:
		if self.value > 0:
			self.value -= 1
			var result =  function.call()
			return result
		else:
			GameManager.playerEffectList.remove_effect(self)
			return []

class UseCardCount_YuanSu extends PlayerEffect:
	func _init() -> void:
		self.name = "使用元素卡牌"
		self.spritePath = "res://assets/image/minion/溢流熔岩.png"
	func round_start() -> void:
		value = 0
	
class YuanSuStatsBuff extends PlayerEffect:
	var stats: Stats
	func _init(stats: Stats) -> void:
		self.name = "能使随从获得属性值的元素使随从额外获得"
		self.spritePath = "res://assets/image/minion/增强的光耀之子.png"
		self.stats = stats
	func get_stats() -> Stats:
		return self.stats
	func description() -> String:
		return name + ": " + str(stats.attack) + "/" + str(stats.health)
	func combine(effect: PlayerEffect) -> bool:
		if self.name == effect.name:
			self.stats = Stats.add_stats(self.stats, effect.stats)
			return true
		return false
