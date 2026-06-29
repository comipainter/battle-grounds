extends BaseAnimation
class_name PlayerAniamtion

var father: Control = GameManager.get_main_scene().get_player_component().get_animation_component()

func play() -> void:
	pass


class ZhanHouChoose extends PlayerAniamtion:
	var collection: MinionCollection
	signal choice_made(minion: Minion)
	signal played
	func _init(_collection: MinionCollection) -> void:
		self.collection = _collection.remove_unvaild()
	func play() -> void:
		self.collection = collection.remove_undesk()
		
		if self.collection.size() == 0:
			choice_made.emit(null)
			return
		
		if DataManager.get_game_info().is_shopping() == false:
			return
			
		# 创建遮罩
		var _overlay: ColorRect = ColorRect.new()
		_overlay.color = Color(0, 0, 0, 0.4)
		_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		father.add_child(_overlay)
		_overlay.global_position = Vector2.ZERO
		_overlay.z_index = 1
		
		# 停止计时
		GameManager.mainScene.get_shop_component().stop_time()
		
		# 等待动画全部完成 # 与战吼效果死锁了！！
		#while GameManager.mainScene.get_shop_component()._is_all_idle() == false:
			#await GameManager.get_tree().process_frame 
		
		# 为场上随从创建按钮
		var zhanhouButtonList: Array[ZhanhouButton] = []
		for minion: Minion in collection.get_array():
			if is_instance_valid(minion):
				var zhanhouButton: ZhanhouButton = DataManager.zhanhouButton.instantiate()
				minion.z_index = 100
				father.add_child(zhanhouButton)
				zhanhouButton.button.z_index = 1000
				zhanhouButton.vfx.z_index = 10
				zhanhouButton.target = minion
				zhanhouButton.button_up.connect(
					func():
						_overlay.queue_free()
						for button in zhanhouButtonList:
							button.queue_free()
						for _minion: Minion in collection.get_array():
							if is_instance_valid(_minion):
								_minion.z_index = 0
						# 开始计时
						GameManager.mainScene.get_shop_component().goon_time()
						choice_made.emit(zhanhouButton.target)
						played.emit()
				)
				zhanhouButtonList.append(zhanhouButton)
		await played

class FaXianChoose extends PlayerAniamtion:
	var choice_array: Array = []
	signal choice_made(minion: Minion)
	func _init(_array: Array) -> void:
		self.choice_array = _array
	func play() -> void:
		if self.choice_array.size() == 0:
			choice_made.emit(null)
			return
			
		if DataManager.get_game_info().is_shopping() == false:
			return
			
		# 创建遮罩
		var _overlay: ColorRect = ColorRect.new()
		_overlay.color = Color(0, 0, 0, 0.4)
		_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		father.add_child(_overlay)
		_overlay.global_position = Vector2.ZERO
		_overlay.z_index = 1
		
		# 停止计时
		GameManager.mainScene.get_shop_component().stop_time()
		
		var container: HBoxContainer = HBoxContainer.new()
		father.add_child(container)
		#container.LayoutPresetMode
		container.set_anchors_preset(Control.PRESET_HCENTER_WIDE, true)
		#container.position = father.size/2
		container.add_theme_constant_override(
			"separation",
			700
			#max(20, 1000 - (self.choice_array.size() * 100))
			#int(container.size.x/self.choice_array.size()+2)
		)
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# 为待选项创建按钮
		var choiceButtonList: Array[ChoiceButton] = []
		for i in range(choice_array.size()):
			var choiceButton: ChoiceButton = DataManager.choiceButton.instantiate()
			choiceButton.ready.connect(
				func():
					choiceButton.set_data(choice_array[i])
			)
			choiceButton.z_index = 10
			container.add_child(choiceButton)
			choiceButton.button_up.connect(
				func():
					for button in choiceButtonList:
						button.queue_free()
					container.queue_free()
					_overlay.queue_free()
					# 开始计时
					GameManager.mainScene.get_shop_component().goon_time()
					choice_made.emit(i)
			)
			choiceButtonList.append(choiceButton)
		
		container.pivot_offset = container.size / 2.0
		var _scale: float = min(1.0, 1.6 - (self.choice_array.size() * 0.2))
		container.scale = Vector2(_scale, _scale)
