extends PlayerAbility
class_name WandAbility

const MAX_LEVEL: int = 5
const SPEED_STEP: float = 60.0
const DAMAGE_STEP: int = 5

## Cadência: cada nível encurta bastante o cooldown de tiro. No nível
## máximo o tiro vira praticamente contínuo enquanto o botão é segurado.
const CADENCE_STEP: float = 0.18
const MIN_COOLDOWN_MULT: float = 0.1

var auto_fire: bool = false
var auto_aim: bool = false
var speed_level: int = 0
var damage_level: int = 0
var cadence_level: int = 0

var speed_bonus: float = 0.0
var damage_bonus: int = 0
var cooldown_mult: float = 1.0

func total_evolution_level() -> int:
	return int(auto_fire) + int(auto_aim) + speed_level + damage_level + cadence_level

func is_fully_evolved() -> bool:
	return auto_fire and auto_aim and speed_level >= MAX_LEVEL and damage_level >= MAX_LEVEL \
		and cadence_level >= MAX_LEVEL

## Ordem: dispara sozinha primeiro, mira sozinha depois — só então
## velocidade/dano/cadência entram no sorteio junto com o resto.
func apply_random_evolution() -> void:
	var options: Array[String] = []
	if not auto_fire:
		options.append("auto_fire")
	elif not auto_aim:
		options.append("auto_aim")
	if speed_level < MAX_LEVEL:
		options.append("speed")
	if damage_level < MAX_LEVEL:
		options.append("damage")
	if cadence_level < MAX_LEVEL:
		options.append("cadence")
	if options.is_empty():
		return

	options.shuffle()
	match options[0]:
		"auto_fire":
			auto_fire = true
		"auto_aim":
			auto_aim = true
		"speed":
			speed_level += 1
			speed_bonus += SPEED_STEP
		"damage":
			damage_level += 1
			damage_bonus += DAMAGE_STEP
		"cadence":
			cadence_level += 1
			cooldown_mult = max(MIN_COOLDOWN_MULT, cooldown_mult - CADENCE_STEP)

## Desfaz totalmente a compra da varinha e tudo que os pergaminhos evoluíram nela.
func reset() -> void:
	unlocked = false
	auto_fire = false
	auto_aim = false
	speed_level = 0
	damage_level = 0
	cadence_level = 0
	speed_bonus = 0.0
	damage_bonus = 0
	cooldown_mult = 1.0
