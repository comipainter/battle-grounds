extends Control

# 节点信息
@onready var nameLabel = $Panel/NameLabel
@onready var costLabel = $Panel/CostLabel
@onready var descriptionLabel = $Panel/DescriptionLabel

var magicInfo: MagicInfo

# 配置方法 
func get_cardInfo() -> MagicInfo:
	return self.magicInfo

func set_cardInfo(cardInfo: CardInfo) -> void:
	self.magicInfo = cardInfo

func set_magicInfo(magicInfo: MagicInfo) -> void:
	self.magicInfo = magicInfo

func use_magicInfo() -> void:
	self.nameLabel.text = self.magicInfo.name
	self.costLabel.text = str(self.magicInfo.cost)
	self.descriptionLabel.text = self.magicInfo.description

func _ready() -> void:
	self.scale = Vector2(1.5, 1.5)
	self.z_index = 1
	self.use_magicInfo()
