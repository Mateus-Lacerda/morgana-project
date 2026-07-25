extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var restart_btn: Button = $Panel/VBox/RestartButton
@onready var options_btn: Button = $Panel/VBox/OptionsButton
@onready var menu_btn: Button = $Panel/VBox/MenuButton
@onready var quit_btn: Button = $Panel/VBox/QuitButton

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

var kb_icons := {
	"IconLeft": preload("res://assets/ui/imagem seta para esquerda.png"),
	"IconRight": preload("res://assets/ui/imagem seta para direita.png"),
	"IconJump": preload("res://assets/ui/imagem seta cima para pulo.png"),
	"IconShoot": preload("res://assets/ui/mouse clique esquerdo disparo mágico.png"),
	"IconAura": preload("res://assets/ui/mouse clique direito aura.png"),
}
var pad_icons := kb_icons  # placeholder

@onready var _labels := {
	"move_label": $ControlsPanel/VBox/ControlsContainer/MoveRow/MoveLabel,
	"jump_label": $ControlsPanel/VBox/ControlsContainer/JumpRow/JumpLabel,
	"shoot_label": $ControlsPanel/VBox/ControlsContainer/ShootRow/ShootLabel,
	"aura_label": $ControlsPanel/VBox/ControlsContainer/AuraRow/AuraLabel,
}
@onready var _icons := {
	"IconLeft": $ControlsPanel/VBox/ControlsContainer/MoveRow/IconLeft,
	"IconRight": $ControlsPanel/VBox/ControlsContainer/MoveRow/IconRight,
	"IconJump": $ControlsPanel/VBox/ControlsContainer/JumpRow/IconJump,
	"IconShoot": $ControlsPanel/VBox/ControlsContainer/ShootRow/IconShoot,
	"IconAura": $ControlsPanel/VBox/ControlsContainer/AuraRow/IconAura,
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	options_btn.pressed.connect(_on_options)
	menu_btn.pressed.connect(_on_menu)
	quit_btn.pressed.connect(_on_quit)
	
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_controls_text()

func _update_controls_text() -> void:
	var is_pad := Input.get_connected_joypads().size() > 0
	var data := JOYPAD_DATA if is_pad else KEYBOARD_DATA
	var icons := pad_icons if is_pad else kb_icons

	for key in _labels:
		if _labels[key]:
			_labels[key].text = data[key]

	for key in _icons:
		if _icons[key]:
			_icons[key].texture = icons[key]

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_controls_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not GameManager.is_game_active and GameManager.current_phase == GameManager.GamePhase.ENDED:
			return # Não pausa se já deu Game Over ou Vitória
		
		if visible:
			_on_resume()
		else:
			_pause_game()

func _pause_game() -> void:
	AudioManager.play_sfx("menu_open")
	get_tree().paused = true
	visible = true
	resume_btn.grab_focus()

func _on_resume() -> void:
	AudioManager.play_sfx("menu_close")
	get_tree().paused = false
	visible = false

func _on_restart() -> void:
	AudioManager.play_sfx("button")
	get_tree().paused = false
	GameManager.clean_for_restart()
	get_tree().reload_current_scene()

func _on_menu() -> void:
	AudioManager.play_sfx("button")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_options() -> void:
	AudioManager.play_sfx("button")
	$OptionsMenu.open()

func _on_quit() -> void:
	AudioManager.play_sfx("button")
	get_tree().quit()
