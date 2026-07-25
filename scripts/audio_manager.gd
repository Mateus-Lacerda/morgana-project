extends Node

const SFX_REGISTRY := {
	# --- UI ---
	"button":       "res://assets/audio/click.mp3",
	"menu_open":    "res://assets/audio/click.mp3",
	"menu_close":   "res://assets/audio/click.mp3",

	# --- Player ---
	"jump":         "res://assets/audio/jump.wav",
	"shoot":        "res://assets/audio/Bow Attack 2.wav",
	"aura":         "res://assets/audio/Firebuff 1.wav",
	"player_hurt":  "res://assets/audio/Ice Freeze 2.wav",

	# --- Enemies ---
	"enemy_hit":    "res://assets/audio/Sword Impact Hit 1.wav",
	"enemy_die":    "res://assets/audio/Sword Impact Hit 2.wav",
	"village_hit":  "res://assets/audio/Door Close 2.wav",

	# --- Orbs ---
	"orb_combo_fire":     "res://assets/audio/Bow Attack 2.wav",
	"orb_blade_hit":      "res://assets/audio/Sword Impact Hit 1.wav",
	"orb_explosive_fire": "res://assets/audio/Firebuff 1.wav",
}

## Override de volume por SFX (em dB). Se não estiver aqui, usa 0.0.
const SFX_VOLUME_DB := {
	"jump": -4.0,
	"enemy_die": 2.0,
}

var _cache: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 12
var current_player_index: int = 0

func _ready() -> void:
	for i in POOL_SIZE:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		players.append(p)

func _get_stream(sound_name: String) -> AudioStream:
	if _cache.has(sound_name):
		return _cache[sound_name]
	
	var path: String = SFX_REGISTRY.get(sound_name, "")
	if path == "":
		push_warning("AudioManager: SFX desconhecido '%s'" % sound_name)
		return null
		
	var stream: AudioStream = load(path)
	_cache[sound_name] = stream
	return stream

func play_sfx(sound_name: String) -> void:
	var stream := _get_stream(sound_name)
	if stream == null:
		return
	
	var p = players[current_player_index]
	p.stream = stream
	p.volume_db = SFX_VOLUME_DB.get(sound_name, 0.0)
	p.play()
	
	current_player_index = (current_player_index + 1) % POOL_SIZE

## Volume em dB. 0 = padrão, -80 = mudo.
func set_master_volume(db: float) -> void:
	var idx = AudioServer.get_bus_index("Master")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)

func set_sfx_volume(db: float) -> void:
	var idx = AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)

func set_music_volume(db: float) -> void:
	var idx = AudioServer.get_bus_index("Music")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)
