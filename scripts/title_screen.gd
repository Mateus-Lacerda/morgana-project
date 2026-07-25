extends Control

# --- Dados de controles por input mode ---
const KEYBOARD_DATA := {
	"move_label": "Mover",
	"jump_label": "Pular (até 4x)",
	"shoot_label": "Disparo Mágico",
	"aura_label": "Aura",
}

const JOYPAD_DATA := {
	"move_label": "Mover",
	"jump_label": "Pular (até 4x)",
	"shoot_label": "Disparo Mágico",
	"aura_label": "Aura",
}

# Texturas de teclado (placeholder também para gamepad por ora)
var kb_icons := {
	"IconLeft": preload("res://assets/ui/imagem seta para esquerda.png"),
	"IconRight": preload("res://assets/ui/imagem seta para direita.png"),
	"IconJump": preload("res://assets/ui/imagem seta cima para pulo.png"),
	"IconShoot": preload("res://assets/ui/mouse clique esquerdo disparo mágico.png"),
	"IconAura": preload("res://assets/ui/mouse clique direito aura.png"),
}

# Quando os ícones de gamepad forem criados, basta duplicar este dict
# com as texturas corretas:
var pad_icons := kb_icons  # placeholder

@onready var _controls: VBoxContainer = $VBox/ControlsContainer
@onready var _labels := {
	"move_label": $VBox/ControlsContainer/MoveRow/MoveLabel,
	"jump_label": $VBox/ControlsContainer/JumpRow/JumpLabel,
	"shoot_label": $VBox/ControlsContainer/ShootRow/ShootLabel,
	"aura_label": $VBox/ControlsContainer/AuraRow/AuraLabel,
}
@onready var _icons := {
	"IconLeft": $VBox/ControlsContainer/MoveRow/IconLeft,
	"IconRight": $VBox/ControlsContainer/MoveRow/IconRight,
	"IconJump": $VBox/ControlsContainer/JumpRow/IconJump,
	"IconShoot": $VBox/ControlsContainer/ShootRow/IconShoot,
	"IconAura": $VBox/ControlsContainer/AuraRow/IconAura,
}

func _ready() -> void:
	$VBox/StartButton.pressed.connect(_on_start_pressed)
	$VBox/OptionsButton.pressed.connect(_on_options_pressed)
	$VBox/StartButton.grab_focus()
	
	MusicManager.play("intro", true)
	
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_controls_text()

func _update_controls_text() -> void:
	var is_pad := Input.get_connected_joypads().size() > 0
	var data := JOYPAD_DATA if is_pad else KEYBOARD_DATA
	var icons := pad_icons if is_pad else kb_icons

	for key in _labels:
		_labels[key].text = data[key]

	for key in _icons:
		_icons[key].texture = icons[key]

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_controls_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("button")
	MusicManager.queue_next("main", true)
	GameManager.clean_for_restart()
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_options_pressed() -> void:
	AudioManager.play_sfx("button")
	$OptionsMenu.open()
