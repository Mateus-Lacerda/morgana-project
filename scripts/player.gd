extends CharacterBody2D
class_name Player

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_box: Area2D = $HurtBox

# --- Movimentação e pulo (mecânica de plataforma, igual ao documento de referência) ---

const MAX_JUMPS: int = 4
# Cada pulo extra impulsiona um pouco menos, para a maga alcançar a horda de
# morcegos no alto da tela sem jamais encostar na barra de vida (UI) no topo.
const JUMP_VELOCITIES: Array[float] = [-400.0, -380.0, -350.0, -310.0]
var jump_count: int = 0

# --- Sistema de Magia e Base de Tempo ---



var fireball_scene = preload("res://scenes/fireball.tscn")
var facing_right: bool = true
var is_paralyzed: bool = false
var is_attacking: bool = false




# Global Magic Cooldown System
var global_cooldown_timer: float = 0.0
var global_cooldown_max: float = 1.0

var cooldown_visualizer: CooldownVisualizer
var aura_visualizer: AuraVisualizer

var wand_ability: WandAbility
var aura_ability: AuraAbility

func start_global_cooldown(duration: float) -> void:
	global_cooldown_timer = duration
	global_cooldown_max = duration
	if cooldown_visualizer:
		cooldown_visualizer.update_cooldown(1.0 - (global_cooldown_timer / global_cooldown_max))

func is_global_cooldown_ready() -> bool:
	return global_cooldown_timer <= 0.0

func _ready() -> void:
	add_to_group("player")
	set_collision_mask_value(2, true) # colide com as paredes invisíveis (Layer 2)
	hurt_box.body_entered.connect(_on_hurt_box_body_entered)
	GameManager.game_over.connect(_on_match_ended)
	GameManager.victory.connect(_on_match_ended)
	animation.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

	# Transforma o Hitbox retangular antigo numa Área Circular 360
	if has_node("Hitbox/CollisionShape2D"):
		var aura_shape = CircleShape2D.new()
		aura_shape.radius = AuraManager.BASE_RADIUS
		$Hitbox/CollisionShape2D.shape = aura_shape
		$Hitbox.position = Vector2.ZERO # Centraliza na maga

	cooldown_visualizer = CooldownVisualizer.new()
	add_child(cooldown_visualizer)
	cooldown_visualizer.initialize(animation)

	aura_visualizer = AuraVisualizer.new()
	add_child(aura_visualizer)

	wand_ability = WandAbility.new()
	add_child(wand_ability)

	aura_ability = AuraAbility.new()
	aura_ability.visual = aura_visualizer # compartilha o anel com o aura_attack, mesmo clique
	add_child(aura_ability)
	aura_ability.unlock() # já começa equipado; só evolui a partir daqui

## Itens já comprados que o pergaminho de evolução pode melhorar.
func get_evolvable_abilities() -> Array:
	var abilities: Array = []
	if wand_ability.unlocked:
		abilities.append(wand_ability)
	if aura_ability.unlocked:
		abilities.append(aura_ability)
	return abilities

func take_damage(amount: int, source: Node = null) -> void:
	# Reservado para uma futura vida da própria maga, se o jogo evoluir para isso.
	pass

func _on_match_ended() -> void:
	is_paralyzed = true

func _on_hurt_box_body_entered(body: Node) -> void:
	if is_paralyzed or not GameManager.is_game_active:
		return
	if body.is_in_group("enemies"):
		_paralyze()

func _paralyze() -> void:
	is_paralyzed = true
	animation.modulate = Color(0.55, 0.55, 1.0)
	_shake_camera()
	AudioManager.play_sfx("player_hurt")

	await get_tree().create_timer(PlayerManager.HIT_FREEZE_TIME).timeout

	is_paralyzed = false
	animation.modulate = Color(1, 1, 1)

func _shake_camera() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var original_offset: Vector2 = camera.offset
	var tween := create_tween()
	for i in range(6):
		var shake_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
		tween.tween_property(camera, "offset", shake_offset, 0.04)
	tween.tween_property(camera, "offset", original_offset, 0.04)

func _aim_direction() -> Vector2:
	if wand_ability.auto_aim:
		var target := _find_nearest_enemy()
		if target:
			return (target.global_position - global_position).normalized()
	return (get_global_mouse_position() - global_position).normalized()

func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.get("is_dead") == true:
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	return nearest

func aura_attack() -> void:
	if not is_attacking and not is_paralyzed and is_global_cooldown_ready():
		is_attacking = true
		animation.play("morgana_attack_aura")
		start_global_cooldown(PlayerManager.AURA_COOLDOWN_MULT * PlayerManager.BASE_GLOBAL_COOLDOWN)
		AudioManager.play_sfx("aura")

		# Efeito Visual 360 e Dano agora são de responsabilidade total da habilidade
		get_tree().create_timer(0.05).timeout.connect(func():
			if aura_ability and aura_ability.unlocked:
				aura_ability.perform_attack()
		)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false

func shoot_magic() -> void:
	is_attacking = true
	animation.play("morgana_attack_shoot")
	start_global_cooldown(PlayerManager.WAND_COOLDOWN_MULT * PlayerManager.BASE_GLOBAL_COOLDOWN)
	AudioManager.play_sfx("shoot")
	var fireball = fireball_scene.instantiate()
	fireball.shooter = self
	fireball.damage = PlayerManager.BASE_WAND_DAMAGE + wand_ability.damage_bonus
	fireball.speed += wand_ability.speed_bonus
	fireball.direction = _aim_direction()
	fireball.global_position = global_position + fireball.direction * 24.0
	get_parent().add_child(fireball)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_active:
		return

	_apply_gravity(delta)

	if is_paralyzed:
		_handle_paralysis()
		return

	_handle_jump()
	_handle_combat()
	_handle_movement()

	move_and_slide()

func _process(delta: float) -> void:
	_update_cooldown(delta)
	_update_animations()

# --- Funções de Componentes do _physics_process ---

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

func _handle_paralysis() -> void:
	velocity.x = 0
	move_and_slide()

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		# Pulo duplo/triplo (ar) emite partícula
		if jump_count > 0:
			_spawn_air_jump_particles()

		velocity.y = JUMP_VELOCITIES[jump_count]
		AudioManager.play_sfx("jump")
		jump_count += 1
		animation.play("morgana_jump")

func _spawn_air_jump_particles() -> void:
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.amount = 20
	p.lifetime = 0.5               # Um pouquinho mais longo pra dar tempo de dispersar
	p.explosiveness = 0.95

	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(14.0, 1.0)

	p.direction = Vector2(0, 1)
	p.spread = 15.0
	p.gravity = Vector2(0, 10)
	p.initial_velocity_min = 5.0
	p.initial_velocity_max = 15.0

	# O SEGREDO DA DISPERSÃO: Aceleração Radial!
	# Começa calmo, mas as partículas são empurradas para longe do centro conforme o tempo passa
	p.radial_accel_min = 30.0
	p.radial_accel_max = 70.0

	p.scale_amount_min = 1.5
	p.scale_amount_max = 2.5

	# Transição Dourada
	var grad = Gradient.new()
	grad.set_color(0, Color(1.0, 0.85, 0.3, 1.0))
	grad.set_color(1, Color(1.0, 0.85, 0.3, 0.0))
	# Mantém bem sólido nos primeiros 40% da vida, depois some
	grad.add_point(0.4, Color(1.0, 0.85, 0.3, 0.9))
	p.color_ramp = grad

	p.global_position = global_position + Vector2(0, 14)
	get_parent().add_child(p)
	p.emitting = true

	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _handle_combat() -> void:
	if (wand_ability.auto_fire or Input.is_action_pressed("shoot_attack")) and is_global_cooldown_ready():
		shoot_magic()
	elif Input.is_action_pressed("aura_attack") and is_global_cooldown_ready():
		aura_attack()

func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * PlayerManager.MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, PlayerManager.MOVE_SPEED)


# --- Funções de Componentes do _process ---

func _update_cooldown(delta: float) -> void:
	if global_cooldown_timer > 0:
		global_cooldown_timer -= delta
		if cooldown_visualizer and global_cooldown_max > 0:
			var progress = 1.0 - (global_cooldown_timer / global_cooldown_max)
			cooldown_visualizer.update_cooldown(progress)
		if global_cooldown_timer <= 0:
			if cooldown_visualizer:
				cooldown_visualizer.play_twinkle()

func _update_animations() -> void:
	if velocity.x > 0:
		facing_right = true
		animation.flip_h = false
	elif velocity.x < 0:
		facing_right = false
		animation.flip_h = true

	if is_paralyzed or is_attacking:
		return

	if is_on_floor():
		if velocity.x != 0:
			animation.play("morgana_walking2")
		else:
			animation.play("morgana_idle")
	else:
		if velocity.y < 0:
			if animation.animation != "morgana_jump":
				animation.play("morgana_jump")
		else:
			if animation.animation != "morgana_fall":
				animation.play("morgana_fall")
