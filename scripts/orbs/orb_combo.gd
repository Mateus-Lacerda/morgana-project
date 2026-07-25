extends OrbBase
class_name OrbCombo

var fireball_scene := preload("res://scenes/fireball.tscn")
var damage_amount: int = 15
var _pierce: bool = false
var _player: Node2D

const SIZE_MULT: float = 0.5

# Bônus de evolução — somados por cima do tier de combo, já que _apply_tier()
# reatribui damage_amount/orbit_speed/scale toda vez que o combo muda.
var _evo_damage_bonus: int = 0
var _evo_speed_bonus: float = 0.0
var _evo_scale_mult: float = 1.0
var _evo_cooldown_mult: float = 1.0

@export_group("Evolução Passiva")
@export var evo_damage_step: int = 15
@export var evo_speed_step: float = 1.0
@export var evo_scale_step: float = 0.2

@export_group("Omni Transformation")
## Transformação final: em vez de mirar só no morcego mais próximo, dispara
## uma saraivada em todas as direções a cada ataque.
@export var omni_bolt_count: int = 8
@export var omni_cooldown_mult: float = 1.6 # compensa o dano de 8 tiros de uma vez
var _omni_fire: bool = false

const POWER_TIERS := [
	{"mult": 10, "damage": 70, "cooldown": 0.2, "radius": 520.0, "orbit_speed": 4.2, "pierce": true, "visual_scale": 1.6, "color": Color(1.0, 0.85, 0.3)},
	{"mult": 8, "damage": 60, "cooldown": 0.35, "radius": 480.0, "orbit_speed": 3.6, "pierce": true, "visual_scale": 1.45, "color": Color(1.0, 0.55, 0.85)},
	{"mult": 5, "damage": 45, "cooldown": 0.5, "radius": 450.0, "orbit_speed": 3.0, "pierce": false, "visual_scale": 1.3, "color": Color(0.75, 0.6, 1.0)},
	{"mult": 3, "damage": 35, "cooldown": 0.65, "radius": 420.0, "orbit_speed": 2.6, "pierce": false, "visual_scale": 1.15, "color": Color(0.55, 0.85, 1.0)},
	{"mult": 2, "damage": 28, "cooldown": 0.8, "radius": 400.0, "orbit_speed": 2.4, "pierce": false, "visual_scale": 1.05, "color": Color(0.6, 0.9, 1.0)},
	{"mult": 1, "damage": 20, "cooldown": 0.9, "radius": 380.0, "orbit_speed": 2.2, "pierce": false, "visual_scale": 1.0, "color": Color(0.75, 0.9, 1.0)},
]

func _ready() -> void:
	super._ready()
	# Órbita mais afastada que a lâmina (contato) — fica evidente que essa
	# orbe ataca à distância em vez de precisar encostar no inimigo.
	orbit_radius = 60.0
	# O Player agora é o "avô" (AIFamiliar -> OrbManager -> Player)
	_player = get_parent().get_parent()
	add_to_group("orb_combo")
	GameManager.combo_changed.connect(_on_combo_changed)
	_apply_tier(_tier_for_multiplier(GameManager.combo_multiplier))

func get_kind_id() -> StringName:
	return &"orb_combo"

func _on_speed_evolved() -> void:
	_evo_speed_bonus += evo_speed_step
	_apply_tier(_tier_for_multiplier(GameManager.combo_multiplier))

func _on_size_evolved() -> void:
	_evo_scale_mult += evo_scale_step
	_evo_speed_bonus += evo_speed_step
	_apply_tier(_tier_for_multiplier(GameManager.combo_multiplier))

func _on_attack_evolved() -> void:
	_evo_damage_bonus += evo_damage_step
	_apply_tier(_tier_for_multiplier(GameManager.combo_multiplier))

func _on_transformed() -> void:
	_omni_fire = true
	if _omni_fire:
		_evo_cooldown_mult *= omni_cooldown_mult
	_apply_tier(_tier_for_multiplier(GameManager.combo_multiplier))

func _on_combo_changed(multiplier: int, _streak: int) -> void:
	_apply_tier(_tier_for_multiplier(multiplier))

func _tier_for_multiplier(multiplier: int) -> Dictionary:
	for tier in POWER_TIERS:
		if multiplier >= tier.mult:
			return tier
	return POWER_TIERS[POWER_TIERS.size() - 1]

func _apply_tier(tier: Dictionary) -> void:
	damage_amount = tier.damage + _evo_damage_bonus
	attack_cooldown = (tier.cooldown * _evo_cooldown_mult)
	detection_radius = tier.radius
	orbit_speed = tier.orbit_speed + _evo_speed_bonus
	_pierce = tier.pierce
	_update_visual(tier.color, tier.visual_scale * _evo_scale_mult)

func _update_visual(color: Color, visual_scale: float) -> void:
	var orb := get_node_or_null("Orb")
	var glow := get_node_or_null("Glow")
	if orb:
		orb.color = color
	if glow:
		glow.color = Color(color.r, color.g, color.b, 0.28)

	var final_scale := visual_scale * SIZE_MULT
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(final_scale, final_scale), 0.35)

func _find_target() -> Node2D:
	# Como essa é uma orbe de combate padrão, ela busca o morcego mais perto
	return get_nearest_entity_in_radius("enemies")

func _execute_attack(target: Node2D) -> void:
	if _omni_fire:
		var angle_step: float = TAU / omni_bolt_count
		for i in range(omni_bolt_count):
			var angle: float = angle_step * i
			_fire_bolt(Vector2(cos(angle), sin(angle)))
	else:
		_fire_bolt((target.global_position - global_position).normalized())

	AudioManager.play_sfx("orb_combo_fire")
	_flash()
	start_cooldown(attack_cooldown)

func _fire_bolt(direction: Vector2) -> void:
	var bolt := fireball_scene.instantiate()
	bolt.shooter = _player
	bolt.damage = damage_amount
	bolt.pierce = _pierce
	bolt.direction = direction
	bolt.global_position = global_position
	# Adiciona o raio no Level (avô do Player)
	_player.get_parent().add_child(bolt)

func _flash() -> void:
	var orb := get_node_or_null("Orb")
	if orb == null:
		return
	var tween := create_tween()
	tween.tween_property(orb, "scale", Vector2(1.6, 1.6), 0.08)
	tween.tween_property(orb, "scale", Vector2(1.0, 1.0), 0.16)
