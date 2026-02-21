class_name ZhanhouChoose

signal choice_made(targetMinion: Minion)

var baseMinion: Minion

var _waiting: bool = false
var choosed_minion: Minion

var fatherNode: Control = GameManager.shopScene.choose

var zhanhouButtonList: Array[Control]
var _overlay: ColorRect

func _init(baseMinion: Minion, cardList: Array[Card]) -> void:
	GameManager.shopScene.move_child(fatherNode, GameManager.shopScene.get_child_count()-1)
	self.baseMinion == baseMinion
	# 创建遮罩层
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.4)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fatherNode.add_child(_overlay)
	
	# 为场上所有随从创建按钮
	for card in cardList:
		var minion: Minion = card
		var zhanhouButton: ZhanhouButton = GameManager.animationAssets.zhanhouButtonTemplate.instantiate()
		zhanhouButton.button.button_up.connect(_on_option_chosed.bind(minion))
		zhanhouButton.z_index = 10
		zhanhouButton.target = minion
		fatherNode.add_child(zhanhouButton)
		zhanhouButtonList.append(zhanhouButton)
		
func _on_option_chosed(minion: Minion) -> void:
	choosed_minion = minion
	_waiting = false

func wait_for_choice() -> Minion:
	_waiting = true
	while _waiting:
		await GameManager.get_tree().process_frame
	return choosed_minion
	
func quit() -> void:
	for zhanhouButton in zhanhouButtonList:
		zhanhouButton.queue_free()
	_overlay.queue_free()
	GameManager.shopScene.move_child(GameManager.shopScene.choose, 0)
