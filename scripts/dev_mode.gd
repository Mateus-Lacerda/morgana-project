extends CanvasLayer

## Painel de depuração estendido.
const TOGGLE_KEYCODE: Key = KEY_QUOTELEFT

var _wave_spin: SpinBox
var _money_spin: SpinBox
var _items_box: VBoxContainer
var _infinite_mode_btn: CheckButton

func _ready() -> void:
	if not OS.has_feature("debug"):
		queue_free()
		return
		
	layer = 100
	visible = false
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == TOGGLE_KEYCODE:
		visible = not visible
		if visible:
			_refresh()
		get_viewport().set_input_as_handled()

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -340.0
	panel.offset_top = -320.0
	panel.offset_right = 340.0
	panel.offset_bottom = 320.0
	add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 14
	scroll.offset_top = 14
	scroll.offset_right = -14
	scroll.offset_bottom = -14
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	var title := Label.new()
	title.text = "MODO DEV — crase (`) pra fechar"
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	# --- Game Rules ---
	vbox.add_child(_create_section_title("Game Rules"))
	_infinite_mode_btn = CheckButton.new()
	_infinite_mode_btn.text = "Modo Infinito (Travar na última Wave)"
	_infinite_mode_btn.toggled.connect(func(t): GameManager.INFINITE_TESTING_MODE = t)
	vbox.add_child(_infinite_mode_btn)
	
	vbox.add_child(_build_wave_section())
	vbox.add_child(_build_money_section())
	
	vbox.add_child(_build_float_param("Vida Máx da Vila", 
		func(): return GameManager.MAX_VILLAGE_INTEGRITY, 
		func(v): GameManager.MAX_VILLAGE_INTEGRITY = v, 
		10.0, 500.0, 10.0))
		
	vbox.add_child(_build_float_param("Total Expected Bats", 
		func(): return GameManager.TOTAL_EXPECTED_BATS, 
		func(v):
			GameManager.TOTAL_EXPECTED_BATS = v
			GameManager.DAMAGE_PER_HIT = 100.0 / v, 
		10.0, 1000.0, 10.0))
		
	# --- Itens (Conceder de graça) ---
	var items_title := _create_section_title("Itens (conceder de graça)")
	vbox.add_child(items_title)

	_items_box = VBoxContainer.new()
	_items_box.add_theme_constant_override("separation", 4)
	vbox.add_child(_items_box)
	
	vbox.add_child(_build_reset_button())

	# --- Player & Magic ---
	vbox.add_child(_create_section_title("Player & Magic"))
	vbox.add_child(_build_float_param("Move Speed", 
		func(): return PlayerManager.MOVE_SPEED, 
		func(v): PlayerManager.MOVE_SPEED = v, 
		100.0, 800.0, 10.0))
	vbox.add_child(_build_float_param("Hit Freeze Time", 
		func(): return PlayerManager.HIT_FREEZE_TIME, 
		func(v): PlayerManager.HIT_FREEZE_TIME = v, 
		0.0, 3.0, 0.05))
	vbox.add_child(_build_float_param("Global Cooldown", 
		func(): return PlayerManager.BASE_GLOBAL_COOLDOWN, 
		func(v): PlayerManager.BASE_GLOBAL_COOLDOWN = v, 
		0.1, 5.0, 0.1))
	vbox.add_child(_build_float_param("Wand CD Mult", 
		func(): return PlayerManager.WAND_COOLDOWN_MULT, 
		func(v): PlayerManager.WAND_COOLDOWN_MULT = v, 
		0.1, 2.0, 0.05))
	vbox.add_child(_build_float_param("Aura CD Mult", 
		func(): return PlayerManager.AURA_COOLDOWN_MULT, 
		func(v): PlayerManager.AURA_COOLDOWN_MULT = v, 
		0.1, 2.0, 0.05))
	vbox.add_child(_build_int_param("Base Wand Damage", 
		func(): return PlayerManager.BASE_WAND_DAMAGE, 
		func(v): PlayerManager.BASE_WAND_DAMAGE = v, 
		1, 500, 5))
		
	# --- Aura Stats ---
	vbox.add_child(_create_section_title("Aura Stats"))
	vbox.add_child(_build_float_param("Base Radius", 
		func(): return AuraManager.BASE_RADIUS, 
		func(v): AuraManager.BASE_RADIUS = v, 
		50.0, 500.0, 5.0))
	vbox.add_child(_build_float_param("Radius Step", 
		func(): return AuraManager.RADIUS_STEP, 
		func(v): AuraManager.RADIUS_STEP = v, 
		0.0, 100.0, 1.0))
	vbox.add_child(_build_int_param("Base Damage", 
		func(): return AuraManager.BASE_DAMAGE, 
		func(v): AuraManager.BASE_DAMAGE = v, 
		10, 1000, 10))
	vbox.add_child(_build_int_param("Damage Step", 
		func(): return AuraManager.DAMAGE_STEP, 
		func(v): AuraManager.DAMAGE_STEP = v, 
		0, 500, 5))
	vbox.add_child(_build_float_param("Trigger Cooldown", 
		func(): return AuraManager.BASE_TRIGGER_COOLDOWN, 
		func(v): AuraManager.BASE_TRIGGER_COOLDOWN = v, 
		0.5, 10.0, 0.1))
	vbox.add_child(_build_float_param("Cooldown Step", 
		func(): return AuraManager.COOLDOWN_STEP, 
		func(v): AuraManager.COOLDOWN_STEP = v, 
		0.0, 2.0, 0.05))
	vbox.add_child(_build_float_param("Min Trigger Cooldown", 
		func(): return AuraManager.MIN_TRIGGER_COOLDOWN, 
		func(v): AuraManager.MIN_TRIGGER_COOLDOWN = v, 
		0.05, 5.0, 0.05))
		
	# --- Economy ---
	vbox.add_child(_create_section_title("Economy"))
	vbox.add_child(_build_int_param("Scroll Base Cost", 
		func(): return EconomyManager.SCROLL_BASE_COST, 
		func(v): EconomyManager.SCROLL_BASE_COST = v, 
		10, 1000, 10))
	vbox.add_child(_build_int_param("Scroll Cost/Level", 
		func(): return EconomyManager.SCROLL_COST_PER_LEVEL, 
		func(v): EconomyManager.SCROLL_COST_PER_LEVEL = v, 
		5, 500, 5))
	vbox.add_child(_build_int_param("Scroll Transform Cost", 
		func(): return EconomyManager.SCROLL_TRANSFORM_COST, 
		func(v): EconomyManager.SCROLL_TRANSFORM_COST = v, 
		100, 5000, 50))
	vbox.add_child(_build_int_param("Cost Orb Blade", 
		func(): return EconomyManager.COST_ORB_BLADE, 
		func(v): EconomyManager.COST_ORB_BLADE = v, 
		10, 2000, 10))
	vbox.add_child(_build_int_param("Cost Orb Explosive", 
		func(): return EconomyManager.COST_ORB_EXPLOSIVE, 
		func(v): EconomyManager.COST_ORB_EXPLOSIVE = v, 
		10, 2000, 10))
	vbox.add_child(_build_int_param("Cost Orb Combo", 
		func(): return EconomyManager.COST_ORB_COMBO, 
		func(v): EconomyManager.COST_ORB_COMBO = v, 
		10, 2000, 10))
	vbox.add_child(_build_int_param("Cost Coin Magnet", 
		func(): return EconomyManager.COST_COIN_MAGNET, 
		func(v): EconomyManager.COST_COIN_MAGNET = v, 
		10, 3000, 10))
		
	var force_btn := Button.new()
	force_btn.text = "Aplicar Status Base no Player (Forçar Recálculo)"
	force_btn.pressed.connect(_force_recalc)
	vbox.add_child(force_btn)

func _create_section_title(text: String) -> Label:
	var l := Label.new()
	l.text = "--- " + text + " ---"
	l.modulate = Color(0.6, 0.8, 1.0)
	return l

func _build_float_param(label_text: String, get_cb: Callable, set_cb: Callable, min_v: float, max_v: float, step_v: float) -> Control:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(240, 0)
	row.add_child(lbl)
	
	var spin := SpinBox.new()
	spin.min_value = min_v
	spin.max_value = max_v
	spin.step = step_v
	spin.value = get_cb.call()
	spin.custom_minimum_size = Vector2(100, 0)
	spin.value_changed.connect(func(val): set_cb.call(val))
	row.add_child(spin)
	return row

func _build_int_param(label_text: String, get_cb: Callable, set_cb: Callable, min_v: int, max_v: int, step_v: int) -> Control:
	return _build_float_param(label_text, get_cb, set_cb, float(min_v), float(max_v), float(step_v))

func _force_recalc() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var player := tree.get_first_node_in_group("player") as Node2D if tree else null
	if player:
		# Recalcula habilidades do player (não perder os upgrades, apenas recarregar as consts)
		player.aura_ability.radius = AuraManager.BASE_RADIUS + (player.aura_ability.radius_level) * AuraManager.RADIUS_STEP
		player.aura_ability.damage = AuraManager.BASE_DAMAGE + (player.aura_ability.damage_level) * AuraManager.DAMAGE_STEP
		player.aura_ability.trigger_cooldown = max(AuraManager.MIN_TRIGGER_COOLDOWN, AuraManager.BASE_TRIGGER_COOLDOWN - (player.aura_ability.cooldown_level) * AuraManager.COOLDOWN_STEP)
		
		# Varinha
		if "fireball" in player:
			player.fireball.damage = PlayerManager.BASE_WAND_DAMAGE + player.wand_ability.damage_bonus
		
	if GameManager.village_integrity > GameManager.MAX_VILLAGE_INTEGRITY:
		GameManager.village_integrity = GameManager.MAX_VILLAGE_INTEGRITY
		GameManager.village_integrity_changed.emit(GameManager.village_integrity)

func _build_wave_section() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = "Wave:"
	row.add_child(label)

	_wave_spin = SpinBox.new()
	_wave_spin.min_value = 1
	_wave_spin.max_value = GameManager.WAVES_CONFIG.size()
	_wave_spin.custom_minimum_size = Vector2(80, 0)
	row.add_child(_wave_spin)

	var go_button := Button.new()
	go_button.text = "Ir pra wave (combate direto)"
	go_button.pressed.connect(func():
		GameManager.dev_set_wave(int(_wave_spin.value) - 1)
	)
	row.add_child(go_button)

	return row

func _build_money_section() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = "Moedas:"
	row.add_child(label)

	_money_spin = SpinBox.new()
	_money_spin.min_value = 0
	_money_spin.max_value = 999999
	_money_spin.step = 10
	_money_spin.custom_minimum_size = Vector2(100, 0)
	row.add_child(_money_spin)

	var set_button := Button.new()
	set_button.text = "Definir"
	set_button.pressed.connect(func():
		GameManager.money = int(_money_spin.value)
		GameManager.money_changed.emit(GameManager.money)
	)
	row.add_child(set_button)

	var max_button := Button.new()
	max_button.text = "+9999"
	max_button.pressed.connect(func():
		GameManager.add_money(9999)
		_money_spin.value = GameManager.money
	)
	row.add_child(max_button)

	return row

func _build_reset_button() -> Control:
	var button := Button.new()
	button.text = "Resetar todos os itens (Apaga Upgrades da Morgana)"
	button.pressed.connect(func():
		ItemManager.reset()
		var tree := Engine.get_main_loop() as SceneTree
		var player := tree.get_first_node_in_group("player") if tree else null
		if player:
			player.aura_ability.reset()
			player.aura_ability.unlock()
			player.wand_ability.reset()
			player.wand_ability.unlock()
		_refresh()
	)
	return button

func _refresh() -> void:
	_infinite_mode_btn.set_pressed_no_signal(GameManager.INFINITE_TESTING_MODE)
	_wave_spin.value = GameManager.current_wave_index + 1
	_money_spin.value = GameManager.money
	_refresh_items_list()

func _refresh_items_list() -> void:
	for child in _items_box.get_children():
		child.queue_free()

	var all_scripts: Array[GDScript] = []
	all_scripts.append_array(Shop.ORB_ITEMS)
	all_scripts.append_array(Shop.SCROLL_ITEMS)
	all_scripts.append_array(Shop.SINGLE_ITEMS)

	for item_script in all_scripts:
		var item = item_script.new()
		_items_box.add_child(_build_item_row(item))

func _build_item_row(item) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = item.display_name
	label.custom_minimum_size = Vector2(280, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	row.add_child(label)

	var grant_button := Button.new()
	grant_button.text = "Conceder"
	grant_button.pressed.connect(func():
		_grant(item)
		_refresh()
	)
	row.add_child(grant_button)

	return row

func _grant(item) -> void:
	if item.stackable:
		item.apply()
	else:
		ItemManager.grant(item)
