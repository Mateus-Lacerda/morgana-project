extends Control

# --- Dados de controles por input mode ---

func _ready() -> void:
	$VBox/StartButton.pressed.connect(_on_start_pressed)
	$VBox/OptionsButton.pressed.connect(_on_options_pressed)
	$VBox/StartButton.grab_focus()
	
	MusicManager.play("intro", true)
	

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
