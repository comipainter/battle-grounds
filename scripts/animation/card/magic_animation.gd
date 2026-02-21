extends CardAnimation
class_name MagicAnimation

func execute() -> void:
	# 子类重写，返回一个可 await 的信号或协程
	pass
		
class RemoveAnimation extends MagicAnimation:
	var magic: Magic
	func _init(magic: Magic):
		self.magic = magic
	func execute() -> void:
		print("执行移除动画")
		if GameManager.is_fighting():
			GameManager.fightScene.delete_card(magic)
		if GameManager.is_shopping():
			GameManager.shopScene.delete_card(magic)
		var tween = magic.create_tween()
		tween.tween_property(magic, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(magic, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_callback(magic.queue_free)
		await tween.finished

class JiuGuanBi extends MagicAnimation:
	var magic: Magic
	func _init(magic: Magic):
		self.magic = magic
	func execute() -> void:
		print("执行酒馆币动画")
		# 开始数值计算
		GameManager.shopScene.add_coin(1)
		GameManager.shopScene.display_coin()
		magic.add_animation(MagicAnimation.RemoveAnimation.new(magic))

class LueDuoZheHeYue extends MagicAnimation:
	var magic: Magic
	func _init(magic: Magic):
		self.magic = magic
	func execute() -> void:
		print("执行掠夺者合约动画")
		# 从酒馆中选择一名海盗
		if GameManager.is_shopping():
			var cardList: Array[Card]
			for card in GameManager.shopScene.shopCardList:
				if card.cardInfo["type"] == "minion":
					if card.cardInfo["race"] == "海盗":
						cardList.append(card)
			cardList.shuffle()
			if cardList.size() >= 1:
				var card = cardList[0]
				# 置入手牌
				GameManager.shopScene.remove_shopCard(card)
				GameManager.shopScene.add_handCard(card)
		magic.add_animation(MagicAnimation.RemoveAnimation.new(magic))
