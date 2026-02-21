class_name PlayerAnimation

func execute():
	pass

class GeLeiSiFaXiEr1 extends PlayerAnimation:
	var restRounds: int = 1
	func execute() -> void:
		restRounds -= 1
		if restRounds == 0:
			GameManager.shopScene.add_coin(3)

class GeLeiSiFaXiEr2 extends PlayerAnimation:
	var restRounds: int = 2
	func execute() -> void:
		restRounds -= 1
		if restRounds == 0:
			GameManager.shopScene.add_coin(3)
