extends Node2D
class_name MolotovZone

var radius: float = 70.0
var dps: float = 10.0
var duration: float = 3.0
var shooter: Node = null

const TICK_INTERVAL: float = 0.5
var _tick_timer: float = 0.0

func _ready() -> void:
	get_tree().create_timer(duration, false).timeout.connect(queue_free)
	_spawn_visual()

func _process(delta: float) -> void:
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = TICK_INTERVAL
		_damage_tick()

func _damage_tick() -> void:
	var dmg := int(round(dps * TICK_INTERVAL))
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.get("is_dead") == true:
			continue
		if global_position.distance_to(enemy.global_position) <= radius:
			enemy.take_damage(dmg, shooter)

func _spawn_visual() -> void:
	var points := PackedVector2Array()
	var segments := 24
	for i in range(segments):
		var angle := TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	var fire_zone := Polygon2D.new()
	fire_zone.polygon = points
	fire_zone.color = Color(1.0, 0.35, 0.05, 0.28)
	add_child(fire_zone)

	var tween := create_tween()
	tween.tween_property(fire_zone, "modulate:a", 0.0, duration)
