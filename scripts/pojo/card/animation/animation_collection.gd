class_name AnimationCollection

var animationArray: Array[BaseAnimation] = []

var is_playing: bool = false
func is_idle() -> bool:
	return !is_playing and animationArray.is_empty()

func add_animation(animation: BaseAnimation) -> void:
	animationArray.append(animation)
	play()

func play_next() -> void:
	if animationArray.is_empty():
		is_playing = false
		return
	var current_animation = animationArray.pop_front()
	await current_animation.play()
	play_next()

func play() -> void:
	if not is_playing:
		if not animationArray.is_empty():
			is_playing = true
			self.play_next()
