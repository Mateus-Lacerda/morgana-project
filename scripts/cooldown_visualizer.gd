extends Node2D
class_name CooldownVisualizer

var _overlay: Node2D
var _particles: CPUParticles2D
var _progress: float = 1.0

func initialize(sprite: CanvasItem) -> void:
	# Configura o overlay de scan
	_overlay = Node2D.new()
	_overlay.draw.connect(_on_overlay_draw)
	# Permite que o overlay desenhe apenas na intersecção opaca do Sprite
	sprite.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	sprite.add_child(_overlay)
	
	# Configura as partículas douradas (twinkling)
	_particles = CPUParticles2D.new()
	_particles.emitting = false
	_particles.one_shot = true
	_particles.explosiveness = 0.85
	_particles.lifetime = 0.6
	_particles.amount = 20
	
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_particles.emission_sphere_radius = 16.0
	
	# Movimento suave subindo e espalhando
	_particles.gravity = Vector2(0, -20)
	_particles.initial_velocity_min = 5.0
	_particles.initial_velocity_max = 15.0
	_particles.radial_accel_min = 15.0
	_particles.radial_accel_max = 30.0
	
	# Tamanhos bem menores, semelhantes ao pulo mágico
	_particles.scale_amount_min = 1.0
	_particles.scale_amount_max = 2.0
	
	_particles.color = Color(1.0, 0.85, 0.3, 0.9) # Dourado base
	
	# Transição suave de opacidade
	var grad = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.9))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	grad.add_point(0.3, Color(1, 1, 1, 0.9)) # Segura sólido um tempinho antes de sumir
	_particles.color_ramp = grad
	
	add_child(_particles)

func update_cooldown(progress: float) -> void:
	_progress = progress
	_overlay.queue_redraw()

func play_twinkle() -> void:
	_particles.restart()

func _on_overlay_draw() -> void:
	if _progress < 1.0:
		var bottom_y = 40.0
		var top_y = -40.0
		var current_y = lerp(bottom_y, top_y, _progress)
		
		# O rect pinta APENAS o corpo do sprite graças ao clip_children
		_overlay.draw_rect(Rect2(-100, current_y, 200, 200), Color(1.0, 0.851, 0.2, 0.3))
