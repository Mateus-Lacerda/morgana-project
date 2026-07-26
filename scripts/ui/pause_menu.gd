extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var restart_btn: Button = $Panel/VBox/RestartButton
@onready var options_btn: Button = $Panel/VBox/OptionsButton
@onready var menu_btn: Button = $Panel/VBox/MenuButton
@onready var quit_btn: Button = $Panel/VBox/QuitButton

# --- Dados de controles por input mode ---

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	options_btn.pressed.connect(_on_options)
	menu_btn.pressed.connect(_on_menu)
	quit_btn.pressed.connect(_on_quit)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
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
