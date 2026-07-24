extends OrbBase
class_name OrbExplosive

@export var damage_amount: int = 20
@export var explosion_radius: float = 70.0

const ATTACK_STEP: int = 5
const EXPLOSION_RADIUS_STEP: float = 16.0
const EXPLOSION_RADIUS_GROWTH: float = 1.5 # cada pergaminho aumenta o próprio incremento seguinte

var projectile_scene := preload("res://scenes/orbs/bomb_projectile.tscn")
var _player: Node2D
var _explosion_radius_step: float = EXPLOSION_RADIUS_STEP

## Transformação final: vira um "molotov" — a explosão deixa uma área em
## chamas que continua causando dano por um tempo.
const MOLOTOV_BURN_DURATION: float = 3.0
const MOLOTOV_DPS_RATIO: float = 0.4 # dano por segundo = % do dano de impacto
var _is_molotov: bool = false

func _ready() -> void:
	super._ready()
	# Órbita mais afastada ainda que a de combo — é a mais "artilheira" das três,
	# fica visualmente clara a diferença entre as três orbes na órbita da maga.
	orbit_radius = 82.0
	# O Player é o "avô" (OrbExplosive -> OrbManager -> Player), igual ao OrbCombo
	_player = get_parent().get_parent()
	attack_cooldown = 2.0

func get_kind_id() -> StringName:
	return &"orb_explosive"

## Escala acelerada de propósito: a bomba deve ficar "mais e mais bombástica"
## a cada pergaminho, então o próprio incremento cresce (não é linear).
func _on_size_evolved() -> void:
	super._on_size_evolved()
	explosion_radius += _explosion_radius_step
	_explosion_radius_step *= EXPLOSION_RADIUS_GROWTH

func _on_transformed() -> void:
	_is_molotov = true

func _on_attack_evolved() -> void:
	damage_amount += ATTACK_STEP

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
		bolt.burn_duration = MOLOTOV_BURN_DURATION
		bolt.burn_dps = damage_amount * MOLOTOV_DPS_RATIO
	bolt.global_position = global_position
	_player.get_parent().add_child(bolt)

	_flash()
	start_cooldown(attack_cooldown)

func _flash() -> void:
	var orb := get_node_or_null("Orb")
	if orb == null:
		return
	var tween := create_tween()
	tween.tween_property(orb, "scale", Vector2(1.5, 1.5), 0.08)
	tween.tween_property(orb, "scale", Vector2(1.0, 1.0), 0.16)
