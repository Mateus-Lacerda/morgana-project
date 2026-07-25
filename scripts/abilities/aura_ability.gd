extends PlayerAbility
class_name AuraAbility

const MAX_LEVEL: int = 5

var auto_trigger: bool = false
var radius_level: int = 0
var damage_level: int = 0
var cooldown_level: int = 0

var radius: float = AuraManager.BASE_RADIUS
var damage: int = AuraManager.BASE_DAMAGE
var trigger_cooldown: float = AuraManager.BASE_TRIGGER_COOLDOWN

var _player: Node2D
var _can_trigger: bool = true

## Pode ser injetado de fora (ver Player._ready) pra compartilhar o mesmo
## anel visual do aura_attack antigo — os dois disparam no mesmo clique
## direito, então usar instâncias separadas fazia dois círculos translúcidos
## se sobreporem e a transparência de cada um somar visualmente com a outra.
var visual: AuraVisualizer

func _ready() -> void:
	_player = get_parent()
	if visual == null:
		visual = AuraVisualizer.new()
		_player.add_child(visual)

func _process(_delta: float) -> void:
	if not unlocked or not GameManager.is_game_active:
		return
	if auto_trigger and _can_trigger:
		_can_trigger = false
		perform_attack()
		get_tree().create_timer(trigger_cooldown, false).timeout.connect(func():
			_can_trigger = true
		)

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
			radius += AuraManager.RADIUS_STEP
		"damage":
			damage_level += 1
			damage += AuraManager.DAMAGE_STEP
		"cooldown":
			cooldown_level += 1
			trigger_cooldown = max(AuraManager.MIN_TRIGGER_COOLDOWN, trigger_cooldown - AuraManager.COOLDOWN_STEP)

## Desfaz totalmente a compra do campo de força e tudo que os pergaminhos evoluíram nele.
func reset() -> void:
	unlocked = false
	auto_trigger = false
	radius_level = 0
	damage_level = 0
	cooldown_level = 0
	radius = AuraManager.BASE_RADIUS
	damage = AuraManager.BASE_DAMAGE
	trigger_cooldown = AuraManager.BASE_TRIGGER_COOLDOWN

func perform_attack() -> void:
	# Só trava expandido (sem recuar) quando é automático e rápido demais pra
	# caber um pulso inteiro entre gatilhos — senão a animação reiniciaria do
	# zero a cada disparo e travaria sempre no começo, nunca abrindo de vez.
	var stay_expanded := auto_trigger and trigger_cooldown < AuraManager.PULSE_DURATION
	visual.play_pulse(radius, stay_expanded)
	for target in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(target):
			continue
		if target.get("is_dead") == true:
			continue
		if _player.global_position.distance_to(target.global_position) <= radius:
			target.take_damage(damage, _player)
