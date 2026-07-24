extends Node2D
class_name AuraVisualizer

var _current_radius: float = 0.0
var _current_alpha: float = 0.0
var _tween: Tween

## Anel contínuo respirando bem devagar em vez de piscar a cada gatilho —
## fica ligado o tempo todo enquanto o campo de força está equipado, num
## ritmo independente da cadência de dano (que só controla quando ele bate).
func start_idle_pulse(base_radius: float, cycle_duration: float = 2.6) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	_current_radius = base_radius * 0.88
	_current_alpha = 0.18

	_tween = create_tween()
	_tween.set_loops()
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.set_parallel(true)
	_tween.tween_property(self, "_current_radius", base_radius * 1.08, cycle_duration / 2.0)
	_tween.tween_property(self, "_current_alpha", 0.4, cycle_duration / 2.0)
	_tween.chain().set_parallel(true)
	_tween.tween_property(self, "_current_radius", base_radius * 0.88, cycle_duration / 2.0)
	_tween.tween_property(self, "_current_alpha", 0.18, cycle_duration / 2.0)

func stop_pulse() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_current_radius = 0.0

func _process(_delta: float) -> void:
	if _current_radius > 0:
		queue_redraw()

func _draw() -> void:
	if _current_radius > 0:
		draw_circle(Vector2.ZERO, _current_radius, Color(0.3, 0.8, 1.0, _current_alpha))
		draw_arc(Vector2.ZERO, _current_radius, 0, TAU, 32, Color(0.8, 0.95, 1.0, _current_alpha * 1.5), 2.0)
