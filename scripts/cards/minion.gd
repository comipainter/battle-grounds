extends Card
class_name Minion

# 节点信息
@onready var attackLabel: Label = $Control/AttackLabel
@onready var healthLabel: Label = $Control/HealthLabel
@onready var minionSprite: Sprite2D = $Control/Sprite/MinionSprite
@onready var backgroundSprite: Sprite2D = $Control/Sprite/BackgroundSprite
@onready var glodenBackgroundSprite: Sprite2D = $Control/Sprite/GlodenBackgroundSprite

var minionInfo: MinionInfo
func set_info(info: CardInfo) -> void:
	self.minionInfo = info
	super.set_info(info)
func get_info() -> CardInfo:
	return self.minionInfo

func get_uniqueId() -> int:
	return self.minionInfo.uniqueId
func get_attack() -> int:
	return self.minionInfo.attack
func get_health() -> int:
	return self.minionInfo.health
func get_sprite() -> Texture:
	return load(self.minionInfo.spritePath)
func get_race() -> String:
	return self.minionInfo.race
func set_golden(gold: bool) -> void:
	if minionInfo.golden: 
		return
	self.minionInfo.golden = gold
	var originInfo: MinionInfo = MinionData.get_minion_by_id(get_id())
	add_info(AddInfo.new(originInfo.attack, originInfo.health))
	if GameManager.is_shopping(): # 如果点金了要在计数器中减1
		GameManager.shopScene.be_golden_sub_card_tripleCheckList(self)
func is_golden() -> bool:
	return self.minionInfo.golden
func add_info(addInfo: AddInfo) -> void:
	self.minionInfo.attack += addInfo.get_attack()
	self.minionInfo.health += addInfo.get_health()
	self.update_info()
func use_info() -> void:
	self.attackLabel.text = str(self.get_attack())
	self.healthLabel.text = str(self.get_health())
	self.minionSprite.texture = self.get_sprite()
	if is_golden():
		glodenBackgroundSprite.visible = true
		backgroundSprite.visible = false
	else:
		glodenBackgroundSprite.visible = false
		backgroundSprite.visible = false
	if self.minionInfo.effectCountAble == true:
		effectCountLabel.text = str(self.minionInfo.effectCount) + " / " + str(self.minionInfo.maxEffectCount)
	else:
		effectCountLabel.text = ""
func update_info() -> void:
	self.attackLabel.text = str(self.get_attack())
	self.healthLabel.text = str(self.get_health())
	if self.minionInfo.effectCountAble == true:
		effectCountLabel.text = str(self.minionInfo.effectCount) + " / " + str(self.minionInfo.maxEffectCount)
	else:
		effectCountLabel.text = ""
func tripleGolden_info(info1: MinionInfo, info2: MinionInfo, info3: MinionInfo) -> void:
	var originInfo: MinionInfo = MinionData.get_minion_by_id(info1.id)
	set_info(originInfo)
	var totalAttack = info1.attack + info2.attack + info3.attack
	var totalHealth = info1.health + info2.health + info3.health
	totalAttack -= originInfo.attack
	totalHealth -= originInfo.health
	minionInfo.attack = totalAttack
	minionInfo.health = totalHealth
	minionInfo.golden = true
	
func _ready() -> void:
	super._ready()
	cardType = GameManager.CARDTYPE.MINION
	use_info()
	
# 悬停相关
func hover() -> void:
	super.hover()
	originCardNode = GameManager.originMinionTemplate.instantiate()
	originCardNode.set_minionInfo(MinionData.get_minion_by_id(get_id()))
	self.add_child(originCardNode)
	originCardNode.set_global_position(self.global_position + Vector2(250, 0))

func exit_hover() -> void:
	super.exit_hover()
	originCardNode.queue_free()
	
# 战斗相关
var attackPrior: int = 0

func take_damage(damage: int) -> void:
	self.cardInfo["health"] -= damage
	update_info()
	
func is_dead() -> bool:
	return get_health() <= 0
	
# 效果计数器
@export var effectCountLabel: Label
func create_effectCount(initNum: int, maxCount: int, function: Callable) -> void:
	self.minionInfo.effectCountAble = true
	self.minionInfo.effectCount = initNum
	self.minionInfo.maxEffectCount = maxCount
	self.minionInfo.effectCountFunction = function
	self.add_animation(MinionAnimation.EffectCount.new(self, minionInfo.effectCount, minionInfo.maxEffectCount))
	
func update_effectCountLabel(currCount: int, maxCount: int) -> void:
	self.effectCountLabel.text = str(currCount) + " / " + str(maxCount)
	
func add_effectCount(num: int) -> void:
	self.minionInfo.effectCount += num
	while self.minionInfo.effectCount >= self.minionInfo.maxEffectCount:
		self.minionInfo.effectCountFunction.call(self)
		self.minionInfo.effectCount -= self.minionInfo.maxEffectCount
	self.add_animation(MinionAnimation.EffectCount.new(self, minionInfo.effectCount, minionInfo.maxEffectCount))

func _on_button_button_down() -> void:
	super._button_down()

func _on_button_button_up() -> void:
	super._button_up()

func _on_button_mouse_entered() -> void:
	super._mouse_entered()

func _on_button_mouse_exited() -> void:
	super._mouse_exited()
