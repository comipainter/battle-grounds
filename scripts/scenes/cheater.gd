extends Control

@export var container: FlowContainer
@export var minionFatherNode: Control

@export var haidaoButton: Button
@export var yuansuButton: Button

var currRace: String = "海盗"

func update():
	var children = container.get_children()
	for child in children:
		child.queue_free()
	for child in minionFatherNode.get_children():
		child.queue_free()
		
	for i in range(5):
		var control = Control.new()
		#control.set_size(Vector2(384, 384))
		container.add_child(control)
	
	for info in GameManager.allMinionInfo:
		var minionInfo: MinionInfo = info.create()
		if minionInfo.race.contains(currRace):
			var control = Control.new()
			container.add_child(control)
			var minion: Minion = GameManager.create_card(minionInfo)
			match currRace:
				"海盗":
					minion.global_position = haidaoButton.global_position
				"元素":
					minion.global_position = yuansuButton.global_position
			minion.set_followNode(control)
			minionFatherNode.add_child(minion)
			minion.create_click(func(pos: Vector2, paramSelf: Minion):
				if GameManager.is_shopping():
					GameManager.shopScene.create_handCard(MinionData.get_minion_by_id(GameManager.allMinionInfo, minionInfo.id), Vector2(0, 0)))
	
	for i in range(5):
		var control = Control.new()
		#control.set_size(Vector2(384, 384))
		container.add_child(control)
	
func _ready() -> void:
	update()

func _on_hai_dao_button_button_up() -> void:
	currRace = "海盗"
	update()

func _on_yuan_su_button_button_up() -> void:
	currRace = "元素"
	update()

func _on_end_button_button_up() -> void:
	self.queue_free()
