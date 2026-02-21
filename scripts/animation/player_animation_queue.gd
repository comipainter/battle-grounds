class_name PlayerAnimationQueue

var queue: Array[PlayerAnimation] = []

func add_animation(animation: PlayerAnimation) -> void:
	queue.append(animation)

# 回合开始效果
func round_start():
	for animation in queue:
		if animation is PlayerAnimation.GeLeiSiFaXiEr1:
			animation.execute()
		elif animation is PlayerAnimation.GeLeiSiFaXiEr2:
			animation.execute()
