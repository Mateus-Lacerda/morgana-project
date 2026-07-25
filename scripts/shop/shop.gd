extends CanvasLayer
class_name Shop

const ORB_ITEMS: Array[GDScript] = [
	preload("res://scripts/items/orb_combo_item.gd"),
	preload("res://scripts/items/orb_blade_item.gd"),
	preload("res://scripts/items/orb_explosive_item.gd"),
]

const SCROLL_ITEMS: Array[GDScript] = [
	preload("res://scripts/items/scroll_orb_combo_item.gd"),
	preload("res://scripts/items/scroll_orb_blade_item.gd"),
	preload("res://scripts/items/scroll_orb_explosive_item.gd"),
	preload("res://scripts/items/scroll_wand_item.gd"),
	preload("res://scripts/items/scroll_aura_item.gd"),
	preload("res://scripts/items/scroll_transform_combo_item.gd"),
	preload("res://scripts/items/scroll_transform_blade_item.gd"),
	preload("res://scripts/items/scroll_transform_explosive_item.gd"),
]

const SINGLE_ITEMS: Array[GDScript] = [
	preload("res://scripts/items/coin_magnet_item.gd"),
]

@onready var shop_ui: Control = $ShopUI
@onready var choice_panel: Panel = $ShopUI/ChoicePanel
@onready var choice_title: Label = $ShopUI/ChoicePanel/VBox/TitleLabel
@onready var choice_hint: Label = $ShopUI/ChoicePanel/VBox/HintLabel
@onready var choice_row: GridContainer = $ShopUI/ChoicePanel/VBox/ChoiceScroll/ChoiceRow
@onready var choice_close_button: Button = $ShopUI/ChoicePanel/VBox/CloseButton

const INTRO_TITLE := "Loja - Prepare-se para a primeira horda"
const INTRO_HINT := "Compre o que o dinheiro der: orbes, pergaminhos de evolução e outros itens. Feche quando estiver pronta."
const WAVE_TITLE_FMT := "Loja - Prepare-se para a horda %d"
const WAVE_HINT := "Compre o que o dinheiro der. A horda só começa quando você fechar a loja."

func _ready() -> void:
	shop_ui.visible = false
	choice_panel.visible = false
	choice_close_button.pressed.connect(_close_shop)
	GameManager.preparation_started.connect(_on_preparation_started)
	_run_first_shop()

## Assim que a partida começa de verdade (fim da contagem regressiva), abre a
## loja completa antes da primeira horda.
func _run_first_shop() -> void:
	# Espera um frame pra garantir que o _ready() do Level (que pausa o jogo
	# pra contagem regressiva) já rodou antes de checarmos is_game_active.
	await get_tree().process_frame
	while not GameManager.is_game_active:
		await get_tree().create_timer(0.2).timeout
	_open_full_shop(INTRO_TITLE, INTRO_HINT)

func _on_preparation_started(wave_num: int) -> void:
	_open_full_shop(WAVE_TITLE_FMT % wave_num, WAVE_HINT)

func _find_manager() -> OrbManager:
	return get_tree().get_first_node_in_group("orb_manager") as OrbManager

## Reúne tudo que dá pra comprar agora: orbes ainda não equipadas (se houver
## slot livre), pergaminhos de evolução pras orbes/habilidades já equipadas, e
## os itens avulsos (ímã) ainda não comprados. Varinha e aura já vêm
## equipadas desde o início — só aparecem os pergaminhos delas.
func _gather_full_shop_items() -> Array[ItemBase]:
	var items: Array[ItemBase] = []

	var manager := _find_manager()
	if manager != null and manager.has_room():
		for item_script in ORB_ITEMS:
			var item: ItemBase = item_script.new()
			if item.is_available():
				items.append(item)

	for item_script in SCROLL_ITEMS:
		var scroll: ItemBase = item_script.new()
		if scroll.is_available():
			items.append(scroll)

	for item_script in SINGLE_ITEMS:
		var single: ItemBase = item_script.new()
		if (single.stackable or not ItemManager.is_owned(single.id)) and single.is_available():
			items.append(single)

	return items

func _open_full_shop(title: String, hint: String) -> void:
	choice_title.text = title
	choice_hint.text = hint
	_refresh_full_shop()

	shop_ui.visible = true
	choice_panel.visible = true
	GameManager.is_game_active = false

## Reconstrói a lista de cartas com base no que ainda está disponível e no
## dinheiro atual. Chamada após cada compra pra manter a loja aberta e
## atualizada, em vez de fechar sozinha.
func _refresh_full_shop() -> void:
	var items := _gather_full_shop_items()

	for child in choice_row.get_children():
		child.queue_free()
	for item in items:
		choice_row.add_child(_build_choice_card(item))

## Tamanho fixo de todo card, sempre — nenhuma parte de conteúdo variável
## (nome, descrição) pode crescer além do que cabe aqui: nome quebra em até
## 2 linhas, descrição fica num scroll interno com altura travada. Assim o
## grid inteiro fica uniforme não importa o tamanho do texto de cada item.
const CARD_SIZE := Vector2(170, 236)
const CARD_NAME_HEIGHT := 34.0
const CARD_DESC_HEIGHT := 70.0

func _build_choice_card(item: ItemBase) -> Control:
	var card := VBoxContainer.new()
	card.custom_minimum_size = CARD_SIZE
	card.clip_contents = true
	card.add_theme_constant_override("separation", 4)

	var icon_stack := _build_icon_stack(item, Vector2(48, 48))
	icon_stack.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.add_child(icon_stack)

	var card_name := Label.new()
	card_name.text = item.display_name
	card_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_name.autowrap_mode = TextServer.AUTOWRAP_WORD
	card_name.custom_minimum_size = Vector2(0, CARD_NAME_HEIGHT)
	card_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(card_name)

	var desc_scroll := ScrollContainer.new()
	desc_scroll.custom_minimum_size = Vector2(0, CARD_DESC_HEIGHT)
	desc_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(desc_scroll)

	var card_desc := Label.new()
	card_desc.text = item.description
	card_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	card_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_desc.add_theme_font_size_override("font_size", 13)
	card_desc.custom_minimum_size = Vector2(CARD_SIZE.x - 20.0, 0)
	desc_scroll.add_child(card_desc)

	var price := item.compute_cost()
	var card_cost := Label.new()
	card_cost.text = "Custo: %d moedas" % price
	card_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(card_cost)

	var buy_button := Button.new()
	buy_button.text = "Comprar"
	buy_button.disabled = GameManager.money < price
	buy_button.pressed.connect(func():
		if ItemManager.purchase(item):
			_refresh_full_shop()
	)
	card.add_child(buy_button)

	return card

## Ícone grande do item (ex: o pergaminho) com a orbe pequena desenhada por
## cima quando houver (ex: a orbe específica que aquele pergaminho evolui).
## A orbe nunca é PNG — é a própria forma (Polygon2D) desenhada por OrbIcon.
func _build_icon_stack(item: ItemBase, size: Vector2) -> Control:
	var stack := Control.new()
	stack.custom_minimum_size = size

	if item.icon_path != "":
		var base_icon := TextureRect.new()
		base_icon.anchor_right = 1.0
		base_icon.anchor_bottom = 1.0
		base_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		base_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		base_icon.texture = load(item.icon_path)
		stack.add_child(base_icon)

	if item.icon_orb_kind != &"":
		# Com pergaminho por baixo, a orbe fica pequena e centralizada por cima
		# dele; sem pergaminho (compra direta da orbe), ela ocupa quase tudo.
		var orb_diameter := size.x * (0.3 if item.icon_path != "" else 0.55)
		var orb_icon := OrbIcon.build(item.icon_orb_kind, orb_diameter)
		var margin := (size.x - orb_diameter) / 2.0
		orb_icon.offset_left = margin
		orb_icon.offset_top = margin
		orb_icon.offset_right = margin + orb_diameter
		orb_icon.offset_bottom = margin + orb_diameter
		stack.add_child(orb_icon)
	elif item.icon_overlay_path != "":
		var overlay := TextureRect.new()
		var margin := size.x * 0.15
		overlay.offset_left = margin
		overlay.offset_top = margin
		overlay.offset_right = size.x - margin
		overlay.offset_bottom = size.y - margin
		overlay.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		overlay.texture = load(item.icon_overlay_path)
		stack.add_child(overlay)

	return stack

func _close_shop() -> void:
	shop_ui.visible = false
	choice_panel.visible = false
	GameManager.is_game_active = true
