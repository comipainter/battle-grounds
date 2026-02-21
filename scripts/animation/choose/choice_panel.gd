class_name ChoicePanel

signal choice_made(index: int)

var _choice_index: int = -1
var _waiting: bool = false

var hbox
var chooseList: Array[ChooseCard]
var _overlay: ColorRect

func _init(optionList: Array) -> void:
	# 创建遮罩层
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 挂载
	var fatherNode = GameManager.shopScene.choose
	hbox = fatherNode.get_child(0)
	hbox.add_theme_constant_override("separation", 700)
	fatherNode.add_child(_overlay)
	fatherNode.move_child(_overlay, 0)
	GameManager.shopScene.move_child(fatherNode, GameManager.shopScene.get_child_count()-1)
	# 为每个选项创建按钮
	for i in range(optionList.size()):
		var option = optionList[i]
		var choose: ChooseCard = GameManager.animationAssets.chooseTemplate.instantiate()
		choose.descriptionLabel.text = option["discription"]
		choose.iconSprite.texture = option["sprite"]
		choose.iconSprite.scale = option["sprite_scale"]
		choose.button.button_up.connect(_on_option_chosed.bind(i))
		
		hbox.add_child(choose)
		chooseList.append(choose)

func _on_option_chosed(index: int) -> void:
	_choice_index = index
	_waiting = false
	choice_made.emit(index)

func wait_for_choice() -> int:
	_waiting = true
	while _waiting:
		await GameManager.get_tree().process_frame
	return _choice_index
	
func quit() -> void:
	for choose in chooseList:
		choose.queue_free()
	_overlay.queue_free()
	GameManager.shopScene.move_child(GameManager.shopScene.choose, 0)
