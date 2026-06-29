extends Control
class_name ChoiceButton

@onready var sprite: Sprite2D = $MinionSprite
@onready var descriptionLabel: Label = $DescriptionLabel
@onready var nameLabel: HandNameLabel = $Name/NameLabel
@onready var healthLabel: Label = $Stats/Health/HealthLabelControl/HealthLabel
@onready var attackLabel: Label = $Stats/Attack/AttackLabelControl/AttackLabel

@onready var statsControl: Control = $Stats

func set_data(data) -> void:
	if data is MinionData:
		sprite.texture = load(data.get_sprite_path())
		descriptionLabel.text = data.get_description()
		nameLabel.text = data.get_card_name()
		healthLabel.text = str(data.get_health())
		attackLabel.text = str(data.get_attack())
		
	elif data is MagicData:
		sprite.texture = load(data.get_sprite_path())
		descriptionLabel.text = data.get_description()
		nameLabel.text = data.get_card_name()
		statsControl.visible = false
		
	elif data is Dictionary:
		sprite.texture = load(data.get("sprite_path"))
		descriptionLabel.text = data.get("description")
		nameLabel.text = data.get("name")
		statsControl.visible = false
	
	healthLabel.add_theme_color_override("font_color", Color("#FFFFFF"))
	attackLabel.add_theme_color_override("font_color", Color("#FFFFFF"))

signal button_up
func _on_button_button_up() -> void:
	button_up.emit()
