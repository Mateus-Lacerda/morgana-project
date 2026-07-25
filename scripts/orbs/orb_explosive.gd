extends OrbBase
class_name OrbExplosive

@export_group("Base Stats (Bomb)")
@export var damage_amount: int = 45
@export var explosion_radius: float = 70.0
@export var attack_cooldown_base: float = 1.2

@export_group("Evolution Scaling")
@export var attack_step: int = 15
@export var explosion_radius_step_val: float = 16.0
@export var explosion_radius_growth: float = 1.5

@export_group("Molotov Transformation")
@export var molotov_burn_duration: float = 3.0
@export var molotov_dps_ratio: float = 0.4

var projectile_scene := preload("res://scenes/orbs/bomb_projectile.tscn")
var _player: Node2D
var _current_radius_step: float

## Transformação final: vira um "molotov" — a explosão deixa uma área em
## chamas que continua causando dano por um tempo.
var _is_molotov: bool = false

func _ready() -> void:
	super._ready()
	# Órbita mais afastada ainda que a de combo — é a mais "artilheira" das três,
	# fica visualmente clara a diferença entre as três orbes na órbita da maga.
	orbit_radius = 82.0
	# O Player é o "avô" (OrbExplosive -> OrbManager -> Player), igual ao OrbCombo
	_player = get_parent().get_parent()
	attack_cooldown = attack_cooldown_base
	_current_radius_step = explosion_radius_step_val

func get_kind_id() -> StringName:
	return &"orb_explosive"

## Escala acelerada de propósito: a bomba deve ficar "mais e mais bombástica"
## a cada pergaminho, então o próprio incremento cresce (não é linear).
func _on_size_evolved() -> void:
	super._on_size_evolved()
	explosion_radius += _current_radius_step
	_current_radius_step *= explosion_radius_growth

func _on_transformed() -> void:
	_is_molotov = true

func _on_attack_evolved() -> void:
	damage_amount += attack_step

func _find_target() -> Node2D:
	return get_nearest_entity_in_radius("enemies")

func _execute_attack(target: Node2D) -> void:
	var direction := (target.global_position - global_position).normalized()
	var bolt := projectile_scene.instantiate()
	bolt.shooter = _player
	bolt.damage = damage_amount
	bolt.explosive = true
	bolt.explosion_radius = explosion_radius
	bolt.direction = direction
	if _is_molotov:
		bolt.leaves_burning_zone = true
		bolt.burn_duration = molotov_burn_duration
		bolt.burn_dps = damage_amount * molotov_dps_ratio
	bolt.global_position = global_position
	_player.get_parent().add_child(bolt)

	AudioManager.play_sfx("orb_explosive_fire")
	_flash()
	start_cooldown(attack_cooldown)

func _flash() -> void:
	var orb := get_node_or_null("Orb")
	if orb == null:
		return
	var tween := create_tween()
	tween.tween_property(orb, "scale", Vector2(1.5, 1.5), 0.08)
	tween.tween_property(orb, "scale", Vector2(1.0, 1.0), 0.16)
