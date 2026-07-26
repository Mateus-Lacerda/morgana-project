extends CanvasLayer

@onready var master_slider: HSlider = $Panel/VBox/MasterSlider
@onready var music_slider: HSlider = $Panel/VBox/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SFXSlider
@onready var back_button: Button = $Panel/VBox/BackButton
@onready var pt_button: Button = $Panel/VBox/LanguageContainer/PTBRButton
@onready var en_button: Button = $Panel/VBox/LanguageContainer/ENButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	back_button.pressed.connect(_on_back_pressed)
	pt_button.pressed.connect(_on_pt_pressed)
	en_button.pressed.connect(_on_en_pressed)
	
	# Oculta inicialmente, se instanciado na cena
	visible = false

func open() -> void:
	AudioManager.play_sfx("menu_open")
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	visible = true
	back_button.grab_focus()

func close() -> void:
	AudioManager.play_sfx("menu_close")
	SettingsManager.save_settings()
	visible = false

func _on_master_changed(value: float) -> void:
	SettingsManager.set_master(value)

func _on_music_changed(value: float) -> void:
	SettingsManager.set_music(value)

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_sfx(value)

func _on_back_pressed() -> void:
	close()

func _on_pt_pressed() -> void:
	AudioManager.play_sfx("button")
	TranslationServer.set_locale("pt_BR")

func _on_en_pressed() -> void:
	AudioManager.play_sfx("button")
	TranslationServer.set_locale("en")
