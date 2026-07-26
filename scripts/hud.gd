extends CanvasLayer

@onready var village_bar: ProgressBar = $TopBar/VillageBar
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var score_label: Label = $BottomRight/ScoreLabel
@onready var combo_label: Label = $BottomRight/ComboLabel
@onready var money_label: Label = $BottomRight/MoneyLabel
@onready var active_items_bar: HBoxContainer = $ActiveItemsBar
@onready var magnet_icon: TextureRect = $ActiveItemsBar/MagnetIcon

var _dynamic_icons: Array[Control] = []
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var result_panel: Panel = $ResultPanel
@onready var result_title: Label = $ResultPanel/VBox/ResultTitle
@onready var result_subtitle: Label = $ResultPanel/VBox/ResultSubtitle
@onready var stats_label: Label = $ResultPanel/VBox/StatsLabel
@onready var restart_button: Button = $ResultPanel/VBox/ButtonRow/RestartButton
@onready var menu_button: Button = $ResultPanel/VBox/ButtonRow/MenuButton

const INDICATOR_SCENE = preload("res://scenes/ui/offscreen_indicator.tscn")
var _active_indicators: Dictionary = {}
var _radar_container: Control

## Minimapa: uma tira simples embaixo mostrando onde a maga está no nível em
## relação à vila. Esses limites têm que bater com limit_left/limit_right da
## Camera2D em level.tscn (hoje 100 e 4200).
const MINIMAP_WIDTH: float = 220.0
const MINIMAP_HEIGHT: float = 10.0
const MINIMAP_WORLD_MIN_X: float = 100.0
const MINIMAP_WORLD_MAX_X: float = 4200.0
const MINIMAP_MARKER_SIZE: float = 8.0
var _minimap_player_marker: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_radar_container = Control.new()
	_radar_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_radar_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_radar_container)

	_build_minimap()

	result_panel.visible = false
	fade_overlay.modulate.a = 0.0
	timer_label.pivot_offset = timer_label.size / 2.0
	village_bar.max_value = GameManager.MAX_VILLAGE_INTEGRITY

	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	GameManager.village_integrity_changed.connect(_on_village_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.combo_changed.connect(_on_combo_changed)
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.victory.connect(_on_victory)
	ItemManager.item_acquired.connect(_on_item_acquired)

	_on_village_changed(GameManager.village_integrity)
	_on_time_changed(GameManager.time_left)
	_on_score_changed(GameManager.score)
	_on_combo_changed(GameManager.combo_multiplier, GameManager.combo_streak)
	_on_money_changed(GameManager.money)
	magnet_icon.visible = ItemManager.is_owned(&"coin_magnet")
	_refresh_active_icons()

var _last_village_value: float = GameManager.MAX_VILLAGE_INTEGRITY

func _on_village_changed(value: float) -> void:
	village_bar.value = value
	if value < _last_village_value:
		_flash_village_bar()
	_last_village_value = value

func _flash_village_bar() -> void:
	village_bar.modulate = Color(1.6, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(village_bar, "modulate", Color(1, 1, 1), 0.3)

var _last_pulsed_second: int = -1

func _on_time_changed(time_left: float) -> void:
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60
	
	if GameManager.current_phase == GameManager.GamePhase.PREPARATION:
		timer_label.text = tr("HUD_PREP") % [minutes, seconds]
		timer_label.remove_theme_color_override("font_color")
	else:
		timer_label.text = tr("HUD_WAVE") % [GameManager.current_wave_index + 1, minutes, seconds]
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
		
		# Apenas pulsa dramático nos últimos 10 segundos da Horda
		if time_left <= 10.0:
			var whole_second := int(ceil(time_left))
			if whole_second != _last_pulsed_second:
				_last_pulsed_second = whole_second
				_pulse_timer()

func _pulse_timer() -> void:
	var tween := create_tween()
	tween.tween_property(timer_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(timer_label, "scale", Vector2(1.0, 1.0), 0.2)

func _on_score_changed(value: int) -> void:
	score_label.text = tr("HUD_SCORE") % value

func _on_combo_changed(multiplier: int, streak: int) -> void:
	if streak >= 2:
		combo_label.text = tr("HUD_COMBO") % [multiplier, streak]
		combo_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		combo_label.text = ""

func _on_money_changed(value: int) -> void:
	money_label.text = tr("HUD_COINS") % value

func _on_item_acquired(item: ItemBase) -> void:
	if item.id == &"coin_magnet":
		magnet_icon.visible = true
	_refresh_active_icons()

## Reconstrói os ícones pequenos ao lado do ímã: uma orbe por orbe equipada
## (a própria forma dela, sem PNG) e um ícone por habilidade desbloqueada.
func _refresh_active_icons() -> void:
	for icon in _dynamic_icons:
		icon.queue_free()
	_dynamic_icons.clear()

	var manager := get_tree().get_first_node_in_group("orb_manager") as OrbManager
	if manager:
		for orb in manager.get_orbs():
			_add_dynamic_icon(OrbIcon.build(orb.get_kind_id(), 28.0))

	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return

	# Campo de força já vem equipado desde o início da partida.
	_add_dynamic_icon(_build_png_icon("res://assets/items/aura_icon_small.png"))
	if player.wand_ability.unlocked:
		_add_dynamic_icon(_build_png_icon("res://assets/items/wand_icon.png"))

func _build_png_icon(path: String) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(path)
	return icon

func _add_dynamic_icon(icon: Control) -> void:
	active_items_bar.add_child(icon)
	_dynamic_icons.append(icon)

func _on_game_over() -> void:
	_show_result(tr("HUD_GAMEOVER_TITLE"), tr("HUD_GAMEOVER_SUBTITLE"), Color(0.85, 0.2, 0.2))

func _on_victory() -> void:
	_show_result(tr("HUD_VICTORY_TITLE"), tr("HUD_VICTORY_SUBTITLE"), Color(1.0, 0.85, 0.3))

func _show_result(title: String, subtitle: String, color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.75, 1.0)
	await tween.finished
	await get_tree().create_timer(0.4).timeout

	result_title.text = title
	result_title.add_theme_color_override("font_color", color)
	result_subtitle.text = subtitle
	stats_label.text = tr("HUD_STATS") % [
		GameManager.enemies_defeated,
		int(round(GameManager.village_integrity / GameManager.MAX_VILLAGE_INTEGRITY * 100.0)),
		GameManager.score,
		GameManager.high_score
	]
	result_panel.visible = true

func _on_restart_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().paused = false
	GameManager.clean_for_restart()
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")

## Tira fina com um marcador fixo (vila) e um marcador móvel (maga), mapeando
## a posição X dela no nível pra dentro da largura fixa da tira.
func _build_minimap() -> void:
	var container := Control.new()
	container.anchor_left = 0.5
	container.anchor_right = 0.5
	container.anchor_top = 1.0
	container.anchor_bottom = 1.0
	container.offset_left = -MINIMAP_WIDTH / 2.0
	container.offset_right = MINIMAP_WIDTH / 2.0
	container.offset_top = -30.0
	container.offset_bottom = -30.0 + MINIMAP_HEIGHT
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.add_child(bg)

	var village_marker := ColorRect.new()
	village_marker.color = Color(1.0, 0.85, 0.3, 1.0)
	village_marker.size = Vector2(MINIMAP_MARKER_SIZE * 0.75, MINIMAP_HEIGHT)
	village_marker.position = Vector2(0, 0)
	container.add_child(village_marker)

	_minimap_player_marker = ColorRect.new()
	_minimap_player_marker.color = Color(0.4, 0.9, 1.0, 1.0)
	_minimap_player_marker.size = Vector2(MINIMAP_MARKER_SIZE * 0.75, MINIMAP_HEIGHT)
	container.add_child(_minimap_player_marker)

func _update_minimap(player_x: float) -> void:
	var span := MINIMAP_WORLD_MAX_X - MINIMAP_WORLD_MIN_X
	var t := clampf((player_x - MINIMAP_WORLD_MIN_X) / span, 0.0, 1.0)
	var usable_width := MINIMAP_WIDTH - _minimap_player_marker.size.x
	_minimap_player_marker.position.x = t * usable_width

func _process(_delta: float) -> void:
	if not GameManager.is_game_active:
		return

	var camera = get_viewport().get_camera_2d()
	if not camera: return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		_update_minimap(player.global_position.x)

	var view_size = get_viewport().get_visible_rect().size
	var cam_center = camera.get_screen_center_position()
	var top_left = cam_center - (view_size / 2.0)
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var offscreen_enemy_ids: Dictionary = {}
	
	for e in enemies:
		if e.get("is_dead"): 
			continue
			
		var ex = e.global_position.x
		var ey = e.global_position.y
		
		var is_offscreen_left = (ex < top_left.x)
		var is_offscreen_right = (ex > top_left.x + view_size.x)
		
		if is_offscreen_left or is_offscreen_right:
			var eid: int = e.get_instance_id()
			offscreen_enemy_ids[eid] = true
			
			var ind = _get_or_create_indicator(eid)
			var screen_y = clamp(ey - top_left.y, 40, view_size.y - 40)
			
			if is_offscreen_left:
				ind.position = Vector2(20, screen_y)
				ind.is_left = true
				ind.update_status(ex < 600.0) # Perto do portão
			else:
				ind.position = Vector2(view_size.x - 20, screen_y)
				ind.is_left = false
				ind.update_status(false)
			
	# Limpeza: Remove os indicadores de inimigos que voltaram para a tela, morreram ou foram deletados
	var ids_to_remove: Array = []
	for eid in _active_indicators.keys():
		if not offscreen_enemy_ids.has(eid):
			ids_to_remove.append(eid)
			
	for eid in ids_to_remove:
		_remove_indicator(eid)

func _get_or_create_indicator(enemy_id: int) -> OffscreenIndicator:
	if not _active_indicators.has(enemy_id):
		var ind = INDICATOR_SCENE.instantiate()
		_radar_container.add_child(ind)
		_active_indicators[enemy_id] = ind
	return _active_indicators[enemy_id]

func _remove_indicator(enemy_id: int) -> void:
	if _active_indicators.has(enemy_id):
		var ind = _active_indicators[enemy_id]
		if is_instance_valid(ind):
			ind.queue_free()
		_active_indicators.erase(enemy_id)
