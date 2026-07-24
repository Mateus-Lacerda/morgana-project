extends PlayerAbility
class_name ForceFieldAbility

const MAX_LEVEL: int = 5
const RADIUS_STEP: float = 20.0
const DAMAGE_STEP: int = 15
const BASE_RADIUS: float = 120.0
const BASE_DAMAGE: int = 60
const BASE_TRIGGER_COOLDOWN: float = 3.0

## Cadência do próprio campo: cada nível encurta o intervalo entre pulsos.
## No nível máximo o campo pulsa quase sem pausa — "sempre ativo".
const COOLDOWN_STEP: float = 0.55
const MIN_TRIGGER_COOLDOWN: float = 0.15

var auto_trigger: bool = false
var radius_level: int = 0
var damage_level: int = 0
var cooldown_level: int = 0

var radius: float = BASE_RADIUS
var damage: int = BASE_DAMAGE
var trigger_cooldown: float = BASE_TRIGGER_COOLDOWN

var _player: Node2D
var _can_trigger: bool = true
var _visual: AuraVisualizer

func _ready() -> void:
	_player = get_parent()
	_visual = AuraVisualizer.new()
	_player.add_child(_visual)

func unlock() -> void:
	super.unlock()
	_visual.start_idle_pulse(radius)

func _process(_delta: float) -> void:
	if not unlocked or not GameManager.is_game_active:
		return
	if not _can_trigger:
		return
	if auto_trigger:
		_trigger()
	elif Input.is_action_just_pressed("aura_attack"):
		_trigger()

func total_evolution_level() -> int:
	return int(auto_trigger) + radius_level + damage_level + cooldown_level

func is_fully_evolved() -> bool:
	return auto_trigger and radius_level >= MAX_LEVEL and damage_level >= MAX_LEVEL \
		and cooldown_level >= MAX_LEVEL

func apply_random_evolution() -> void:
	var options: Array[String] = []
	if not auto_trigger:
		options.append("auto_trigger")
	if radius_level < MAX_LEVEL:
		options.append("radius")
	if damage_level < MAX_LEVEL:
		options.append("damage")
	if cooldown_level < MAX_LEVEL:
		options.append("cooldown")
	if options.is_empty():
		return

	options.shuffle()
	match options[0]:
		"auto_trigger":
			auto_trigger = true
		"radius":
			radius_level += 1
			radius += RADIUS_STEP
			_visual.start_idle_pulse(radius) # refaz o pulso com o novo tamanho base
		"damage":
			damage_level += 1
			damage += DAMAGE_STEP
		"cooldown":
			cooldown_level += 1
			trigger_cooldown = max(MIN_TRIGGER_COOLDOWN, trigger_cooldown - COOLDOWN_STEP)

## Desfaz totalmente a compra do campo de força e tudo que os pergaminhos evoluíram nele.
func reset() -> void:
	unlocked = false
	auto_trigger = false
	radius_level = 0
	damage_level = 0
	cooldown_level = 0
	radius = BASE_RADIUS
	damage = BASE_DAMAGE
	trigger_cooldown = BASE_TRIGGER_COOLDOWN
	_visual.stop_pulse()

func _trigger() -> void:
	_can_trigger = false
	# O anel visual já pulsa continuamente (ver AuraVisualizer.start_idle_pulse);
	# aqui só aplica o dano, sem precisar de um flash à parte por gatilho.
	for target in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(target):
			continue
		if target.get("is_dead") == true:
			continue
		if _player.global_position.distance_to(target.global_position) <= radius:
			target.take_damage(damage, _player)
	get_tree().create_timer(trigger_cooldown).timeout.connect(func():
		_can_trigger = true
	)
