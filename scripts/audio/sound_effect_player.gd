extends Node
class_name SoundEffectPlayer

# 音效播放器池 - 支持并行播放多个音效
var _player_pool: Array[AudioStreamPlayer] = []
var _max_players: int = 16  # 最大同时播放的音效数量
var _default_volume_db: float = -30.0  # 默认音量

func _ready():
	# 预创建播放器池
	for i in _max_players:
		var player = AudioStreamPlayer.new()
		player.volume_db = _default_volume_db
		player.finished.connect(_on_player_finished.bind(player))
		add_child(player)
		_player_pool.append(player)

## 播放音效
## stream: 音频流
## volume_db: 音量
## pitch_scale: 音调缩放
func play(stream: AudioStream, volume_db: float = _default_volume_db, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return

	var player = _get_available_player()
	if player == null:
		# 池已满，复用最早播放的播放器
		player = _player_pool[0]
		player.stop()

	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

## 播放音效并等待播放完成（用于需要等待音效播放完毕的场景）
func play_async(stream: AudioStream, volume_db: float = _default_volume_db, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return

	play(stream, volume_db, pitch_scale)
	# 注意：这个方法不阻塞，只是触发播放

## 停止所有音效
func stop_all() -> void:
	for player in _player_pool:
		if player.playing:
			player.stop()

## 设置所有播放器的音量
func set_volume(volume_db: float) -> void:
	_default_volume_db = volume_db
	for player in _player_pool:
		player.volume_db = volume_db

## 获取当前正在播放的音效数量
func get_playing_count() -> int:
	var count := 0
	for player in _player_pool:
		if player.playing:
			count += 1
	return count

## 获取一个可用的播放器
func _get_available_player() -> AudioStreamPlayer:
	for player in _player_pool:
		if not player.playing:
			return player
	return null

## 播放器播放结束回调
func _on_player_finished(player: AudioStreamPlayer) -> void:
	# 播放结束，播放器自动变为可用状态
	player.stream = null
	player.pitch_scale = 1.0
