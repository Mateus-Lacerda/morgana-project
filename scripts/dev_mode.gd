extends CanvasLayer

## Painel de depuração, só pra testes: aperte a tecla de crase (`) pra abrir/
## fechar. Deixa pular pra qualquer wave e conceder qualquer item de graça
## (ignora custo e as regras normais de disponibilidade da loja), além de
## resetar tudo de volta ao estado inicial sem precisar recarregar a cena.
## Usa crase em vez de uma tecla de função porque o macOS costuma interceptar
## F1-F12 pro sistema (Mission Control, brilho etc.) antes do jogo recebê-las.
const TOGGLE_KEYCODE: Key = KEY_QUOTELEFT

var _wave_spin: SpinBox
var _money_spin: SpinBox
var _items_box: VBoxContainer

func _ready() -> void:
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
	panel.offset_left = -270.0
	panel.offset_top = -300.0
	panel.offset_right = 270.0
	panel.offset_bottom = 300.0
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
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	var title := Label.new()
	title.text = "MODO DEV — crase (`) pra fechar"
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	vbox.add_child(_build_wave_section())
	vbox.add_child(_build_money_section())
	vbox.add_child(_build_reset_button())

	var items_title := Label.new()
	items_title.text = "Itens (conceder de graça, ignora custo/limites)"
	vbox.add_child(items_title)

	_items_box = VBoxContainer.new()
	_items_box.add_theme_constant_override("separation", 4)
	vbox.add_child(_items_box)

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
	button.text = "Resetar todos os itens"
	button.pressed.connect(func():
		ItemManager.reset()
		# Campo de força não é mais comprado (já vem equipado de fábrica),
		# então o ItemManager não sabe resetá-lo — faz direto aqui.
		var tree := Engine.get_main_loop() as SceneTree
		var player := tree.get_first_node_in_group("player") as Player if tree else null
		if player:
			player.force_field_ability.reset()
			player.force_field_ability.unlock()
		_refresh()
	)
	return button

func _refresh() -> void:
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
		var item: ItemBase = item_script.new()
		_items_box.add_child(_build_item_row(item))

func _build_item_row(item: ItemBase) -> Control:
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

## Ignora custo e checagens de disponibilidade — é o próprio propósito do modo dev.
func _grant(item: ItemBase) -> void:
	if item.stackable:
		item.apply()
	else:
		ItemManager.grant(item)
