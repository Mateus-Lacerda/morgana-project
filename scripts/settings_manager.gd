extends Node

const SETTINGS_PATH := "user://settings.cfg"

var master_volume: float = 1.0 # 0.0 a 1.0 (linear)
var sfx_volume: float = 1.0
var music_volume: float = 1.0

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master", 1.0)
		sfx_volume = config.get_value("audio", "sfx", 1.0)
		music_volume = config.get_value("audio", "music", 1.0)
	apply_volumes()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("audio", "music", music_volume)
	config.save(SETTINGS_PATH)

func apply_volumes() -> void:
	AudioManager.set_master_volume(linear_to_db(master_volume))
	AudioManager.set_sfx_volume(linear_to_db(sfx_volume))
	AudioManager.set_music_volume(linear_to_db(music_volume))

func set_master(linear: float) -> void:
	master_volume = linear
	AudioManager.set_master_volume(linear_to_db(linear))
	
func set_sfx(linear: float) -> void:
	sfx_volume = linear
	AudioManager.set_sfx_volume(linear_to_db(linear))

func set_music(linear: float) -> void:
	music_volume = linear
	AudioManager.set_music_volume(linear_to_db(linear))
