class_name PlayerAnimation

func execute():
	pass

class Choose extends PlayerAnimation:
	var optionList: Array
	func _init(optionList: Array) -> void:
		self.optionList = optionList
	func execute() -> void:
		var choice_panel = ChoicePanel.new(self.optionList)
		var choice = await choice_panel.wait_for_choice()
		choice_panel.quit()
		if choice == 0:
			GameManager.playerEffectList.add_effect(PlayerEffect.GeLeiSiFaXiEr1.new(2))
		if choice == 1:
			GameManager.playerEffectList.add_effect(PlayerEffect.GeLeiSiFaXiEr2.new(4))
		
class zhanHouChoose extends PlayerAnimation:
	var cardList: Array[Card]
	signal choice_made(minion: Minion)
	func _init(cardList: Array) -> void:
		self.cardList = cardList
	func execute() -> void:
		var zhanhouChoose = ZhanhouChoose.new(cardList)
		var choosed_minion: Minion = await zhanhouChoose.wait_for_choice()
		zhanhouChoose.quit()
		choice_made.emit(choosed_minion)
		
