extends Control
class_name MinionInfoDisplay

# 节点信息
@export var minionSprite: Sprite2D
@export var minionSprite2: Sprite2D
@export var levelSprite: Sprite2D
@export var attackLabel: Label
@export var healthLabel: Label
@export var raceLabel: Label

@export var nameLabel: Label
@export var descriptionLabel: Label

@export var effectFlowContainer: FlowContainer 

var minionInfo: MinionInfo

var start_ronghe: bool = false
var referMinionSprite: Sprite2D
var referMinionSprite2: Sprite2D

# 配置方法 
func get_cardInfo() -> MinionInfo:
	return self.minionInfo

func set_cardInfo(cardInfo: CardInfo) -> void:
	self.minionInfo = cardInfo

func set_minionInfo(info: MinionInfo) -> void:
	self.minionInfo = info

func use_minionInfo() -> void:
	if minionInfo.is_ronghe():
		start_ronghe = true
	else:
		minionSprite.texture = load(minionInfo.spritePath)
	if minionInfo.golden == true:
		minionSprite.material.set_shader_parameter("enable", true)
	else:
		minionSprite.material.set_shader_parameter("enable", false)
	
	raceLabel.text = minionInfo.race
	attackLabel.text = str(minionInfo.attack)
	healthLabel.text = str(minionInfo.health)
	
	levelSprite.texture = GameManager.levelSpriteTemplate[minionInfo.level]
	levelSprite.scale = GameManager.levelSpriteScale[minionInfo.level]
	
	nameLabel.text = minionInfo.name
	if minionInfo.name.length() >= 7:
		# 获取当前字号并减去 4
		nameLabel.add_theme_font_size_override("font_size", nameLabel.get_theme_font_size("font_size") - 8)
	descriptionLabel.text = minionInfo.description
	
	for baseMinionInfo in minionInfo.get_baseMinionInfoList():
		var effectPanel: EffectPanel = GameManager.effectPanelTemplate.instantiate()
		effectPanel.set_baseMinionInfo(baseMinionInfo)
		effectFlowContainer.add_child(effectPanel)
	
	for effect in minionInfo.minionEffectList.get_list():
		var effectPanel: EffectPanel = GameManager.effectPanelTemplate.instantiate()
		effectPanel.set_minionEffect(effect)
		effectFlowContainer.add_child(effectPanel)
	
func _ready() -> void:
	#self.scale = Vector2(1.5, 1.5)
	self.z_index = 1
	self.use_minionInfo()
	
func _process(delta: float) -> void:
	if start_ronghe:
		minionSprite.modulate = referMinionSprite.modulate
		minionSprite2.modulate = referMinionSprite2.modulate
		if minionSprite != referMinionSprite:
			minionSprite.texture = referMinionSprite.texture
		if minionSprite2 != referMinionSprite2:
			minionSprite2.texture = referMinionSprite2.texture
