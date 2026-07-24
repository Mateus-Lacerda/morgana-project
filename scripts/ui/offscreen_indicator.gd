extends Control
class_name OffscreenIndicator

var is_left: bool = false

func update_status(is_critical: bool) -> void:
	if is_critical:
		modulate = Color(1.0, 0.0, 0.0, 1.0) # Vermelho puro e maior
		scale = Vector2(1.5, 1.5)
	else:
		if is_left:
			modulate = Color(1.0, 0.2, 0.2, 0.85) # Vermelho alerta
			scale = Vector2(1.0, 1.0)
		else:
			modulate = Color(1.0, 0.6, 0.1, 0.5) # Laranja e menor (direita)
			scale = Vector2(0.8, 0.8)
