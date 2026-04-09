extends Card
class_name Magic

# 节点信息
@onready var costLabel: Label = $Control/CostLabel
@onready var magicSprite: Sprite2D = $Control/Sprite/MagicSprite

var magicInfo: MagicInfo
func set_info(info: CardInfo) -> void:
	self.magicInfo = info
	super.set_info(info)
func get_info() -> MagicInfo:
	return magicInfo

func get_cost() -> int:
	return self.magicInfo.cost
func get_sprite() -> Texture:
	return load(self.magicInfo.spritePath)
func use_info() -> void:
	self.costLabel.text = str(self.get_cost())
	self.magicSprite.texture = self.get_sprite()
func update_info() -> void:
	self.costLabel.text = str(self.get_cost())

func _ready() -> void:
	super._ready()
	cardType = GameManager.CARDTYPE.MAGIC
	use_info()
	
# 悬停相关
var magicInfoDisplay: MagicInfoDisplay
func hover() -> void:
	super.hover()
	magicInfoDisplay = GameManager.magicInfoDisplayTemplate.instantiate()
	magicInfoDisplay.set_magicInfo(MagicData.get_magic_by_id(GameManager.allMagicInfo, get_id()))
	self.add_child(magicInfoDisplay)
	magicInfoDisplay.set_global_position(self.global_position + Vector2(250, 0))

func exit_hover() -> void:
	super.exit_hover()
	magicInfoDisplay.queue_free()

func _on_button_button_down() -> void:
	super._button_down()


func _on_button_button_up() -> void:
	super._button_up()


func _on_button_mouse_entered() -> void:
	super._mouse_entered()


func _on_button_mouse_exited() -> void:
	super._mouse_exited()
