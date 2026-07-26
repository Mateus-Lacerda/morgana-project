extends Node

const MUSIC_REGISTRY := {
	"intro": "res://assets/audio/music/INTRO-Sem Torre, Só Morgana.mp3",
	"main":  "res://assets/audio/music/SEM INTRO-Sem Torre, Só Morgana.mp3",
}

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer
var _queued_track: String = ""
var _current_track: String = ""
var _current_loop: bool = false
var _queued_loop: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player_a = AudioStreamPlayer.new()
	_player_b = AudioStreamPlayer.new()
	_player_a.bus = "Music"
	_player_b.bus = "Music"
	add_child(_player_a)
	add_child(_player_b)
	_active_player = _player_a
	_player_a.finished.connect(_on_track_finished.bind(_player_a))
	_player_b.finished.connect(_on_track_finished.bind(_player_b))

func play(track_name: String, loop: bool = true) -> void:
	_queued_track = ""
	_current_track = track_name
	_current_loop = loop
	var stream := _load_track(track_name)
	if stream == null:
		return
	stream.loop = false
	_active_player.stop()
	_active_player.stream = stream
	_active_player.play()

func queue_next(track_name: String, loop: bool = true) -> void:
	_queued_track = track_name
	_queued_loop = loop
	_current_loop = false

func change_now(track_name: String, loop: bool = true, fade_time: float = 0.5) -> void:
	_queued_track = ""
	_current_track = track_name
	_current_loop = loop
	var next_player := _inactive_player()
	var stream := _load_track(track_name)
	if stream == null:
		return
	stream.loop = false
	next_player.stream = stream
	next_player.volume_db = -40.0
	next_player.play()
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_active_player, "volume_db", -40.0, fade_time)
	tween.parallel().tween_property(next_player, "volume_db", 0.0, fade_time)
	tween.finished.connect(func():
		_active_player.stop()
		_active_player.volume_db = 0.0
		_active_player = next_player
	)

func stop(fade_time: float = 0.5) -> void:
	_queued_track = ""
	_current_track = ""
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_active_player, "volume_db", -40.0, fade_time)
	tween.finished.connect(func():
		_active_player.stop()
		_active_player.volume_db = 0.0
	)

func get_current_track() -> String:
	return _current_track

func _on_track_finished(player: AudioStreamPlayer) -> void:
	if player != _active_player:
		return
	if _queued_track != "":
		var next_track := _queued_track
		var next_loop := _queued_loop
		_queued_track = ""
		play(next_track, next_loop)
	elif _current_loop:
		player.play()

func _inactive_player() -> AudioStreamPlayer:
	return _player_b if _active_player == _player_a else _player_a

func _load_track(track_name: String) -> AudioStream:
	var path: String = MUSIC_REGISTRY.get(track_name, "")
	if path == "":
		push_warning("MusicManager: Track desconhecida '%s'" % track_name)
		return null
	return load(path)
