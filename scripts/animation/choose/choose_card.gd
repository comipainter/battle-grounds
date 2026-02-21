class_name ChooseCard extends Control

@export var button: Button
@export var descriptionLabel: Label
@export var iconSprite: Sprite2D

func _ready() -> void:
	self.z_index = 10
	button.z_index = 11
	
