extends Node2D
class_name AuraVisualizer

const EXPAND_DURATION: float = 0.16
const HOLD_DURATION: float = 0.28
const RECEDE_DURATION: float = 0.45
## Duração total de um pulso — usada pelo campo de força pra saber se a
## cadência está rápida demais pra caber um pulso inteiro entre gatilhos.
const PULSE_DURATION: float = EXPAND_DURATION + HOLD_DURATION + RECEDE_DURATION

var _current_radius: float = 0.0
var _current_alpha: float = 0.0
var _tween: Tween

## Toca um pulso: expande, **segura no tamanho máximo por um instante** e só
## depois recua até sumir — sem a pausa no ápice o olho não registra o
## tamanho de verdade, porque a animação já começa a encolher assim que
## termina de abrir. Só aparece quando o campo é ativado de verdade, não
## fica ambiente. `stay_expanded` (só quando auto + cadência muito rápida)
## faz o pulso ficar travado no ápice em vez de tentar reiniciar do zero a
## cada disparo, o que senão prende a animação sempre no começo.
func play_pulse(max_radius: float, stay_expanded: bool) -> void:
	var mid_animation := _tween != null and _tween.is_valid()

	if mid_animation and stay_expanded:
		_tween.kill()
		_current_radius = max_radius
		_current_alpha = 0.35
		return

	if mid_animation:
		_tween.kill()

	_current_radius = 14.0
	_current_alpha = 0.7

	_tween = create_tween()
	_tween.tween_property(self, "_current_radius", max_radius, EXPAND_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(HOLD_DURATION)
	_tween.set_parallel(true)
	_tween.tween_property(self, "_current_radius", 0.0, RECEDE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "_current_alpha", 0.0, RECEDE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _process(_delta: float) -> void:
	if _current_radius > 0.0:
		queue_redraw()

func _draw() -> void:
	if _current_radius <= 0.0:
		return
	draw_circle(Vector2.ZERO, _current_radius, Color(0.3, 0.8, 1.0, _current_alpha))
	draw_arc(Vector2.ZERO, _current_radius, 0, TAU, 32, Color(0.8, 0.95, 1.0, clampf(_current_alpha * 1.5, 0.0, 1.0)), 2.0)
