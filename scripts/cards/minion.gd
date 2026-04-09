extends Card
class_name Minion

# 节点信息
@onready var attackLabel: Label = $Control/AttackLabel
@onready var healthLabel: Label = $Control/HealthLabel
@onready var minionSprite: Sprite2D = $Control/Sprite/MinionSprite
@onready var backgroundSprite: Sprite2D = $Control/Sprite/BackgroundSprite
@onready var glodenBackgroundSprite: Sprite2D = $Control/Sprite/GlodenBackgroundSprite
@onready var shengduSprite: Sprite2D = $Control/Sprite/ShengdunSprite
@onready var chaofengSprite: Sprite2D = $Control/Sprite/ChaofengSprite
@onready var fengnuParticles: GPUParticles2D = $Control/Sprite/FengnuParticles
@onready var animationFather: Control = $AnimationFather # 挂载节点的动画
@onready var minionFather: Control = $MinionFather # 挂载融合组件

var initBaseMinionList: Array[Minion] = []
func add_initBaseMinion(baseMinion: Minion) -> void:
	initBaseMinionList.append(baseMinion)
func unsee() -> void:
	$Control.visible = false

func is_idle() -> bool:
	if super.is_idle():
		if is_ronghe():
			for baseMinion in minionFather.get_children():
				if is_instance_valid(baseMinion):
					if not baseMinion.is_idle():
						return false
		return true
	return false

var minionInfo: MinionInfo
func set_info(info: CardInfo) -> void:
	self.minionInfo = info
	super.set_info(info)
func get_info() -> CardInfo:
	return self.minionInfo
func get_minionInfo() -> MinionInfo:
	return self.minionInfo

func get_uniqueId() -> int:
	return self.minionInfo.uniqueId
func get_attack() -> int:
	return self.minionInfo.attack
func get_health() -> int:
	return self.minionInfo.health
func get_sprite() -> Texture:
	return load(self.minionInfo.spritePath)
func get_spritePath() -> String:
	return minionInfo.spritePath
func get_stats() -> Stats:
	return minionInfo.get_stats()
func set_stats(stats: Stats) -> void:
	minionInfo.set_stats(stats)
	update_info()
func is_equal(judgeMinion: Minion) -> bool:
	return self == judgeMinion or (
		self == judgeMinion.get_parent().get_parent() or \
		judgeMinion == self.get_parent().get_parent()
	)
func get_race() -> String:
	return self.minionInfo.race
func is_ronghe() -> bool:
	return minionInfo.is_ronghe()
func is_be_ronghe() -> bool:
	return minionInfo.is_be_ronghe()
func is_shengdun() -> bool:
	return minionInfo.shengdun
func set_shengdu(able: bool) -> void:
	minionInfo.shengdun = able
	shengduSprite.visible = able
func is_chaofeng() -> bool:
	return minionInfo.chaofeng
func set_chaofeng(able: bool) -> void:
	minionInfo.chaofeng = able
	chaofengSprite.visible = able
func is_fengnu() -> bool:
	return minionInfo.fengnu
func set_golden(gold: bool) -> void:
	if minionInfo.golden: 
		return
	self.minionInfo.golden = gold
	var originInfo: MinionInfo = MinionData.get_minion_by_id(GameManager.allMinionInfo, get_id())
	add_stats(Stats.new(originInfo.attack, originInfo.health))
func is_golden() -> bool:
	return self.minionInfo.golden
func add_stats(addStas: Stats) -> void:
	minionInfo.add_stats(addStas)
	self.update_info()
func use_info() -> void:
	attackLabel.text = str(get_attack())
	healthLabel.text = str(get_health())
	if minionInfo.is_ronghe():
		var textureList: Array[Texture2D] = []
		for baseMinionInfo in minionInfo.get_baseMinionInfoList():
			textureList.append(load(baseMinionInfo.spritePath))
		minionSprite.texture_list = textureList
		minionSprite.start = true
	else:
		minionSprite.texture = get_sprite()
	if is_golden():
		glodenBackgroundSprite.visible = true
		backgroundSprite.visible = true
	else:
		glodenBackgroundSprite.visible = false
		backgroundSprite.visible = true
	shengduSprite.visible = minionInfo.shengdun
	chaofengSprite.visible = minionInfo.chaofeng
	fengnuParticles.visible = minionInfo.fengnu
	if minionInfo.effectCountAble == true:
		update_effectCountLabel()
	if minionInfo.boostCountAble == true:
		boostCountSprite.visible = true
		update_boostCountLabel()
	if minionInfo.clockAble == true: # 只能出现在商店页面的场上
		if GameManager.is_shopping():
			if is_belong_desk():
				update_clock()
func update_info() -> void:
	self.attackLabel.text = str(self.get_attack())
	self.healthLabel.text = str(self.get_health())
	if self.minionInfo.effectCountAble == true:
		effectCountLabel.text = str(self.minionInfo.effectCount) + " / " + str(self.minionInfo.effectCountLimit)
	else:
		effectCountLabel.text = ""
	shengduSprite.visible = minionInfo.shengdun
	fengnuParticles.visible = minionInfo.fengnu
		
func tripleGolden_info(info1: MinionInfo, info2: MinionInfo, info3: MinionInfo) -> void:
	var originInfo: MinionInfo = MinionData.get_minion_by_id(GameManager.allMinionInfo, info1.id)
	set_info(originInfo)
	var totalAttack = info1.attack + info2.attack + info3.attack
	var totalHealth = info1.health + info2.health + info3.health
	totalAttack -= originInfo.attack
	totalHealth -= originInfo.health
	minionInfo.attack = totalAttack
	minionInfo.health = totalHealth
	minionInfo.golden = true
	if info1.boostCountAble or info2.boostCountAble or info3.boostCountAble:
		minionInfo.boostCountAble = true
		minionInfo.boostCount = max(info1.boostCount, info2.boostCount, info3.boostCount)
	if info1.effectCountAble or info2.effectCountAble or info3.effectCountAble:
		minionInfo.effectCountAble = true
		minionInfo.effectCount = max(info1.effectCount, info2.effectCount, info3.effectCount)
		minionInfo.effectCountLimit = max(info1.effectCountLimit, info2.effectCountLimit, info3.effectCountLimit)
	
func _ready() -> void:
	super._ready()
	cardType = GameManager.CARDTYPE.MINION
	for baseMinion in initBaseMinionList:
		minionFather.add_child(baseMinion)
		baseMinion.position = Vector2(0, 0)
		baseMinion.unsee()
	use_info()
	
# 悬停相关
var minionInfoDisplay: MinionInfoDisplay
func hover() -> void:
	super.hover()
	minionInfoDisplay = GameManager.minionInfoDisplayTemplate.instantiate()
	minionInfoDisplay.set_minionInfo(minionInfo)
	minionInfoDisplay.referMinionSprite = minionSprite
	minionInfoDisplay.referMinionSprite2 = minionSprite.minionSprite2
	self.add_child(minionInfoDisplay)
	minionInfoDisplay.set_global_position(self.global_position + Vector2(250, 0))

func exit_hover() -> void:
	super.exit_hover()
	minionInfoDisplay.queue_free()
	
# 战斗相关
var attackPrior: bool = false

func take_damage(damage: int) -> void:
	if minionInfo.shengdun == true:
		minionInfo.shengdun = false
	else:
		minionInfo.health -= damage
	update_info()
	add_animation(MinionAnimation.GetDamage.new(self))
	
func is_dead() -> bool:
	return get_health() <= 0
	
# 附加效果
func add_minionEffect(minionEffect: MinionEffect) -> void:
	if minionInfo.minionEffectList.add_effect(minionEffect):
		minionEffect.use(self)
	
# 效果计数器
@export var effectCountLabel: Label
func create_effectCount(initCount: int, maxCount: int, function: Callable) -> void:
	minionInfo.effectCountAble = true
	minionInfo.effectCount = initCount
	minionInfo.effectCountLimit = maxCount
	self.add_animation(MinionAnimation.EffectCount.new(self, minionInfo.effectCount, minionInfo.effectCountLimit))
	minionInfo.effectCountFunction = function
	
func update_effectCountLabel() -> void:
	if minionInfo.effectCountAble:
		effectCountLabel.text = str(minionInfo.effectCount) + " / " + str(minionInfo.effectCountLimit)
	
func add_effectCount(addCount: int) -> void:
	minionInfo.effectCount += addCount
	while minionInfo.effectCount >=minionInfo.effectCountLimit:
		minionInfo.effectCountFunction.call(self)
		minionInfo.effectCount -= minionInfo.effectCountLimit
	self.add_animation(MinionAnimation.EffectCount.new(self, minionInfo.effectCount, minionInfo.effectCountLimit))

func get_effectCount() -> int:
	return minionInfo.effectCount

# 提升计数器
@export var boostCountLabel: Label
@export var boostCountSprite: Sprite2D
func create_boostCount(initCount: int) -> void:
	minionInfo.boostCountAble = true
	boostCountSprite.visible = true
	minionInfo.boostCount = initCount
	update_boostCountLabel()
func add_boostCount(addCount: int) -> void:
	minionInfo.boostCount += addCount
	update_boostCountLabel()
func update_boostCountLabel() -> void:
	if minionInfo.boostCountAble:
		boostCountLabel.text = str(minionInfo.boostCount)
func get_boostCount() -> int:
	return minionInfo.boostCount
	
# 定时器
@export var clock: Clock
func create_clock(roundTime: int, function: Callable) -> void:
	minionInfo.clockAble = true
	minionInfo.clockRoundTime = roundTime
	minionInfo.clockFunction = function
	clock.start(roundTime, function.bind(self))
func update_clock() -> void:
	if minionInfo.clockAble:
		clock.start(minionInfo.clockRoundTime, minionInfo.clockFunction.bind(self))
func close_clock() -> void:
	clock.close()

# 点击器
@export var click: Control
@export var clickSprite: Sprite2D
@export var clickRegion: Control
func create_click(function: Callable, clickSpritePath: String = "", clickSpriteScale: Vector2 = Vector2(1,1), clickSpriteFunction: Callable = func():pass) -> void:
	minionInfo.clickAble = true
	minionInfo.clickFunction = function
	minionInfo.clickIdle = true
	minionInfo.clickSpritePath = clickSpritePath
	minionInfo.clickSpriteScale = clickSpriteScale
	minionInfo.clickSpriteFunction = clickSpriteFunction
	update_click()
		
func update_click() -> void:
	if minionInfo.clickAble:
		if minionInfo.clickSpritePath != "":
			clickSprite.texture = load(minionInfo.clickSpritePath)
			clickSprite.scale = minionInfo.clickSpriteScale
		
func _on_click() -> bool:
	#if is_belong_desk():
	if minionInfo.clickAble:
		if minionInfo.clickIdle:
			if minionInfo.clickFunction.call(get_global_mouse_position(), self): # 如果点击有效
				if not minionInfo.clickSpritePath == "":
					minionInfo.clickSpriteFunction.call(clickSprite, minionInfo)
				return true
			else:
				return false
		else:
			return true
	return false
	
func close_click() -> void:
	minionInfo.clickAble = false
	minionInfo.clickIdle = false
	clickSprite.texture = null
	
static func ronghe(minion1: Minion, minion2: Minion) -> Minion:
	var newInfo: MinionInfo = MinionInfo.create_ronghe(minion1.get_info(), minion2.get_info())
	# 触发融合动画
	MinionAnimationCheck.ronghe(newInfo, minion1, minion2)
	MinionAnimationCheck.ronghe(newInfo, minion2, minion1)
	while !minion1.is_idle() or !minion2.is_idle():
		await GameManager.get_tree().process_frame
	return GameManager.shopScene.create_handCard(newInfo, (minion1.global_position+minion2.global_position)/2)
	
func _on_button_button_down() -> void:
	if _on_click() == false:
		super._button_down()

func _on_button_button_up() -> void:
	super._button_up()

func _on_button_mouse_entered() -> void:
	super._mouse_entered()

func _on_button_mouse_exited() -> void:
	super._mouse_exited()
