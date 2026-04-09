class_name PlayerAnimationQueue

var is_playing: bool = false

var queue: Array[PlayerAnimation] = []

func is_idle() -> bool:
	return !is_playing and queue.is_empty()

func add_animation(animation: PlayerAnimation) -> void:
	queue.append(animation)

func play_next() -> void:
	if queue.is_empty():
		is_playing = false
		return
	var current_animation = queue.pop_front()
	await current_animation.execute()
	play_next()

func play() -> void:
	if not is_playing:
		if not queue.is_empty():
			is_playing = true
			self.play_next()
