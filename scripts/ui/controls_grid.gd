extends GridContainer
class_name ControlsGrid

const KEYBOARD_DATA := {
	"move_label": "CTRL_MOVE",
	"jump_label": "CTRL_JUMP",
	"shoot_label": "CTRL_SHOOT",
	"aura_label": "CTRL_AURA",
}

const JOYPAD_DATA := {
	"move_label": "CTRL_MOVE",
	"jump_label": "CTRL_JUMP",
	"shoot_label": "CTRL_SHOOT",
	"aura_label": "CTRL_AURA",
}

var kb_icons := {
	"IconLeft": preload("res://assets/ui/imagem seta para esquerda.png"),
	"IconRight": preload("res://assets/ui/imagem seta para direita.png"),
	"IconJump": preload("res://assets/ui/imagem seta cima para pulo.png"),
	"IconShoot": preload("res://assets/ui/mouse clique esquerdo disparo mágico.png"),
	"IconAura": preload("res://assets/ui/mouse clique direito aura.png"),
}

var pad_icons := kb_icons  # placeholder

@onready var _labels: Dictionary = {
	"move_label": $MoveLabel,
	"jump_label": $JumpLabel,
	"shoot_label": $ShootLabel,
	"aura_label": $AuraLabel,
}

@onready var _icons: Dictionary = {
	"IconLeft": $MoveIcons/IconLeft,
	"IconRight": $MoveIcons/IconRight,
	"IconJump": $IconJump,
	"IconShoot": $IconShoot,
	"IconAura": $IconAura,
}

func _ready() -> void:
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
