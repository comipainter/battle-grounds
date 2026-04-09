extends Control

class_name EffectTab

@export var effectFlowContainer: FlowContainer

func _ready() -> void:
	for playerEffect in GameManager.playerEffectList.get_list():
		var effectPanel: EffectPanel = GameManager.effectPanelTemplate.instantiate()
		effectPanel.set_playerEffect(playerEffect)
		effectFlowContainer.add_child(effectPanel)

func _on_end_button_button_up() -> void:
	self.queue_free()
