extends Control
class_name EffectTab

@onready var info: PlayerInfo = DataManager.get_player_info()

@onready var container: FlowContainer = $ScrollContainer/EffectFlowContainer

func _ready() -> void:
	for effect: PlayerEffect in info.get_player_effect_collection().get_array():
		var panel: EffectPanel = DataManager.effectPanelScene.instantiate()
		container.add_child(panel)
		panel.display(effect)

func _on_end_button_button_up() -> void:
	self.queue_free()
