extends Node

var click_sfx = preload("res://assets/audio/click.mp3")
var jump_sfx = preload("res://assets/audio/jump.wav")
var shoot_sfx = preload("res://assets/audio/Bow Attack 2.wav")
var aura_sfx = preload("res://assets/audio/Firebuff 1.wav")
var player_hurt_sfx = preload("res://assets/audio/Ice Freeze 2.wav")
var village_hit_sfx = preload("res://assets/audio/Door Close 2.wav")
var enemy_hit_sfx = preload("res://assets/audio/Sword Impact Hit 1.wav")
var enemy_die_sfx = preload("res://assets/audio/Sword Impact Hit 2.wav")

var sounds: Dictionary = {
	"jump": jump_sfx,
	"shoot": shoot_sfx,
	"aura": aura_sfx,
	"player_hurt": player_hurt_sfx,
	"enemy_hit": enemy_hit_sfx,
	"enemy_die": enemy_die_sfx,
	"village_hit": village_hit_sfx,
	"button": click_sfx
}

var players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 12
var current_player_index: int = 0

func _ready() -> void:
	for i in POOL_SIZE:
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		players.append(p)

func play_sfx(sound_name: String) -> void:
	if not sounds.has(sound_name):
		return
	
	# Round-robin: Pega sempre o próximo player do pool. 
	# Isso garante que se o pool lotar (ex: arquivo de som com muito silêncio no final),
	# o sistema força a execução cortando o som mais antigo da fila.
	var p = players[current_player_index]
	p.stream = sounds[sound_name]
	p.play()
	
	current_player_index = (current_player_index + 1) % POOL_SIZE
