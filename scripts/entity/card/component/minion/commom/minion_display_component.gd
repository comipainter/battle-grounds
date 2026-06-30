extends MinionComponent
class_name MinionDisplayComponent

# 节点信息
@onready var minionSprite: Sprite2D = $Panel/MinionSprite
@onready var minionSprite2: Sprite2D = $Panel/MinionSprite2
@onready var levelComponent: CardLevelComponent = $Panel/Level
@onready var attackLabel: Label = $Panel/Stats/VBoxContainer/Attack/CenterContainer/HBoxContainer/AttackLabel
@onready var healthLabel: Label = $Panel/Stats/VBoxContainer/Health/CenterContainer/HBoxContainer/HealthLabel
@onready var raceLabel: Label = $Panel2/Control/CenterContainer/VBoxContainer/RaceLabel

@onready var nameLabel: Label = $Panel2/Control/CenterContainer/VBoxContainer/NameLabel
@onready var descriptionLabel: Label = $Panel2/Control/CenterContainer/VBoxContainer/DescriptionLabel

@onready var effectFlowContainer: FlowContainer = $Control/EffectFlowContainer

var info: MinionInfo = null

func set_minion(_minion: Minion):
	minion = _minion
	info = minion.get_info()
	minion.get_interaction_component().hover_started.connect(start)
	minion.get_interaction_component().hover_ended.connect(close)
	
func start() -> void:
	self.visible = true
	use_info()
	
func close() -> void:
	self.visible = false
	
var start_ronghe: bool = false
var referMinionSprite: Sprite2D
var referMinionSprite2: Sprite2D

# 配置方法 
func use_info() -> void:
	if info.is_ronghe():
		start_ronghe = true
	else:
		minionSprite.texture = load(info.spritePath)
	if info.golden == true:
		minionSprite.material.set_shader_parameter("enable", true)
	else:
		minionSprite.material.set_shader_parameter("enable", false)
	
	raceLabel.text = MinionUtils.get_race_name(info.get_race())
	attackLabel.text = str(info.get_stats().get_attack())
	healthLabel.text = str(info.get_stats().get_health())
	
	levelComponent.set_level(info.get_level())
	levelComponent.use_info()
	
	nameLabel.text = info.get_card_name()
	if info.name.length() >= 7:
		# 获取当前字号并减去 4
		nameLabel.add_theme_font_size_override("font_size", nameLabel.get_theme_font_size("font_size") - 4)
	if info.is_golden():
		descriptionLabel.text = info.get_goldenDescription()
	else:
		descriptionLabel.text = info.get_description()
	
	while effectFlowContainer.get_child_count() != 0:
		effectFlowContainer.get_child(0).free()
	
	for baseMinion in minion.get_base_minion_collection().get_array():
		var effectPanel: EffectPanel = DataManager.effectPanelScene.instantiate()
		effectFlowContainer.add_child(effectPanel)
		effectPanel.display_base_minion(baseMinion)
	
	for effect in minion.get_info().get_effect_collection().get_array():
		var effectPanel: EffectPanel = DataManager.effectPanelScene.instantiate()
		effectFlowContainer.add_child(effectPanel)
		effectPanel.display_minion_effect(effect)
	
func _ready() -> void:
	self.z_index = 1
	
func _process(delta: float) -> void:
	if start_ronghe:
		if minion.get_info().is_shopping_shop():
			referMinionSprite = minion.get_shop_info_component().backgroundComponent.rongheSprite
			referMinionSprite2 = minion.get_shop_info_component().backgroundComponent.rongheSprite2
		elif minion.get_info().is_desk():
			referMinionSprite = minion.get_desk_info_component().backgroundComponent.rongheSprite
			referMinionSprite2 = minion.get_desk_info_component().backgroundComponent.rongheSprite2
		elif minion.get_info().is_hand():
			referMinionSprite = minion.get_hand_info_component().backgroundComponent.rongheSprite
			referMinionSprite2 = minion.get_hand_info_component().backgroundComponent.rongheSprite2
		else:
			return
		minionSprite.modulate = referMinionSprite.modulate
		minionSprite2.modulate = referMinionSprite2.modulate
		minionSprite.texture = referMinionSprite.texture
		minionSprite2.texture = referMinionSprite2.texture
