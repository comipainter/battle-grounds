extends AudioStreamPlayer

class_name AudioManager

# 定义一个队列，用来存储待播放的音频资源
var audio_queue: Array = []
# 标记当前是否正在播放
var is_playing: bool = false

# --- 公共方法：外部调用这个方法来添加音频 ---
func play_audio_stream(stream: AudioStream):
	if stream == null:
		return
	
	# 采用模式： 如果没有音频则播放，否则忽略音频
	if not is_playing:
		audio_queue.append(stream)
		_next_in_queue()

func _next_in_queue():
	if audio_queue.size() == 0:
		is_playing = false
		return
	
	is_playing = true
	
	var next_stream = audio_queue.pop_front()
	
	# 赋值给播放器并播放
	self.stream = next_stream
	self.play()

# --- 信号连接：当音频播放结束时自动调用 ---
func _ready():
	# 连接 finished 信号，当一首歌播完时，自动触发 _on_player_finished
	self.connect("finished", Callable(self, "_on_player_finished"))

func _on_player_finished():
	_next_in_queue()
