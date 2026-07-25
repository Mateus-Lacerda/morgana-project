extends OrbBase
class_name OrbBlade

@export_group("Base Stats (Garlic)")
@export var damage_amount: int = 25
@export var contact_radius: float = 110.0
@export var hit_cooldown: float = 0.1

@export_group("Evolution Scaling")
@export var attack_step: int = 12
@export var contact_radius_step: float = 15.0
@export var blade_scale_step: float = 0.05
@export var orbit_radius_step: float = 25.0
@export var orbit_speed_step: float = 1.5

@export_group("Final Transformation")
## Transformação final: a lâmina cresce bastante e passa a perseguir o
## morcego gigante mais próximo em vez de só orbitar esperando contato.
@export var transform_scale_mult: float = 2.0
@export var transform_radius_mult: float = 1.4
@export var transform_damage_mult: float = 2.0
@export var chase_speed: float = 240.0
@export var chase_range: float = 520.0

func _ready() -> void:
	super._ready()
	detection_radius = contact_radius
	attack_cooldown = hit_cooldown

func get_kind_id() -> StringName:
	return &"orb_blade"

## Cresce mais rápido que o padrão de OrbBase: é a proposta da lâmina, uma
## área de contato que fica bem maior a cada pergaminho.
func _on_size_evolved() -> void:
	scale *= 1.0 + blade_scale_step
	orbit_radius += orbit_radius_step
	contact_radius += contact_radius_step
	detection_radius = contact_radius

func _on_speed_evolved() -> void:
	orbit_speed += orbit_speed_step

func _on_attack_evolved() -> void:
	damage_amount += attack_step

func _on_transformed() -> void:
	scale *= transform_scale_mult
	contact_radius *= transform_radius_mult
	detection_radius = contact_radius
	damage_amount = int(damage_amount * transform_damage_mult)

func _compute_position(delta: float, orbit_position: Vector2) -> Vector2:
	if is_transformed:
		var giant := _find_giant_target()
		if giant:
			var player := get_parent().get_parent() as Node2D # OrbManager -> Player
			var target_local := giant.global_position - player.global_position
			return position.move_toward(target_local, chase_speed * delta)
		# Sem gigante à vista: volta pra órbita deslizando, em vez de saltar
		# de posição instantaneamente (o que parecia a lâmina "sumir e reaparecer").
		return position.move_toward(orbit_position, chase_speed * delta)
	return orbit_position

func _find_giant_target() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := chase_range
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
	AudioManager.play_sfx("orb_blade_hit")
	_flash()
	start_cooldown(attack_cooldown)

func _flash() -> void:
	var orb := get_node_or_null("Orb")
	if orb == null:
		return
	var tween := create_tween()
	tween.tween_property(orb, "scale", Vector2(1.4, 1.4), 0.06)
	tween.tween_property(orb, "scale", Vector2(1.0, 1.0), 0.12)
