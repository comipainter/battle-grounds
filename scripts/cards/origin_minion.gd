extends Control
# 节点信息
@onready var nameLabel = $Panel/NameLabel
@onready var raceLabel = $Panel/RaceLabel
@onready var attackLabel = $Panel/AttackLabel
@onready var healthLabel = $Panel/HealthLabel
@onready var descriptionLabel = $Panel/DescriptionLabel
@onready var levelSprite = $Panel/LevelSprite

var minionInfo: MinionInfo

# 配置方法 
func get_cardInfo() -> MinionInfo:
	return self.minionInfo

func set_cardInfo(cardInfo: CardInfo) -> void:
	self.minionInfo = cardInfo

func set_minionInfo(info: MinionInfo) -> void:
	self.minionInfo = info

func use_minionInfo() -> void:
	self.nameLabel.text = self.minionInfo.name
	self.raceLabel.text = self.minionInfo.race
	self.attackLabel.text = str(self.minionInfo.attack)
	self.healthLabel.text = str(self.minionInfo.health)
	self.descriptionLabel.text = self.minionInfo.description
	self.levelSprite.texture = GameManager.levelSpriteTemplate[self.minionInfo.level]
	self.levelSprite.scale = GameManager.levelSpriteScale[self.minionInfo.level]
	
func _ready() -> void:
	self.scale = Vector2(1.5, 1.5)
	self.z_index = 1
	self.use_minionInfo()
