extends AudioStreamPlayer
class_name BgmPlayer

func play_bgm(stream: AudioStream) -> void:
	stop()
	self.stream = stream
	play()

func _on_player_finished():
	play_bgm(GameManager.bgmAsset.get_random_bgm())

# --- 信号连接：当音频播放结束时自动调用 ---
func _ready():
	# 连接 finished 信号，当一首歌播完时，自动触发 _on_player_finished
	self.connect("finished", Callable(self, "_on_player_finished"))
	
