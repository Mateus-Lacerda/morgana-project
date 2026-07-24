extends OrbBase
class_name OrbBlade

@export var damage_amount: int = 8
@export var contact_radius: float = 90.0
@export var hit_cooldown: float = 0.35

const ATTACK_STEP: int = 4
const CONTACT_RADIUS_STEP: float = 22.0
const BLADE_SCALE_STEP: float = 0.22

## Transformação final: a lâmina cresce bastante e passa a perseguir o
## morcego gigante mais próximo em vez de só orbitar esperando contato.
const TRANSFORM_SCALE_MULT: float = 1.7
const TRANSFORM_RADIUS_MULT: float = 1.4
const TRANSFORM_DAMAGE_MULT: float = 1.5
const CHASE_SPEED: float = 240.0
const CHASE_RANGE: float = 520.0

func _ready() -> void:
	super._ready()
	detection_radius = contact_radius
	attack_cooldown = hit_cooldown

func get_kind_id() -> StringName:
	return &"orb_blade"

## Cresce mais rápido que o padrão de OrbBase: é a proposta da lâmina, uma
## área de contato que fica bem maior a cada pergaminho.
func _on_size_evolved() -> void:
	scale *= 1.0 + BLADE_SCALE_STEP
	orbit_radius += 10.0
	contact_radius += CONTACT_RADIUS_STEP
	detection_radius = contact_radius

func _on_attack_evolved() -> void:
	damage_amount += ATTACK_STEP

func _on_transformed() -> void:
	scale *= TRANSFORM_SCALE_MULT
	contact_radius *= TRANSFORM_RADIUS_MULT
	detection_radius = contact_radius
	damage_amount = int(damage_amount * TRANSFORM_DAMAGE_MULT)

func _compute_position(delta: float, orbit_position: Vector2) -> Vector2:
	if is_transformed:
		var giant := _find_giant_target()
		if giant:
			var player := get_parent().get_parent() as Node2D # OrbManager -> Player
			var target_local := giant.global_position - player.global_position
			return position.move_toward(target_local, CHASE_SPEED * delta)
		# Sem gigante à vista: volta pra órbita deslizando, em vez de saltar
		# de posição instantaneamente (o que parecia a lâmina "sumir e reaparecer").
		return position.move_toward(orbit_position, CHASE_SPEED * delta)
	return orbit_position

func _find_giant_target() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := CHASE_RANGE
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.get("is_dead") == true:
			continue
		if enemy.get("bat_type") != "giant":
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	return nearest

func _find_target() -> Node2D:
	# Lâmina giratória: só "acha" alvo quando ele já está encostando na órbita
	return get_nearest_entity_in_radius("enemies")

func _execute_attack(target: Node2D) -> void:
	target.take_damage(damage_amount, self)
	_flash()
	start_cooldown(attack_cooldown)

func _flash() -> void:
	var orb := get_node_or_null("Orb")
	if orb == null:
		return
	var tween := create_tween()
	tween.tween_property(orb, "scale", Vector2(1.4, 1.4), 0.06)
	tween.tween_property(orb, "scale", Vector2(1.0, 1.0), 0.12)
