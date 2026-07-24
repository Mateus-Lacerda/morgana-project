extends ItemBase
class_name OrbComboItem

const ORB_SCENE: PackedScene = preload("res://scenes/orbs/ai_familiar.tscn")

func _init() -> void:
	id = &"orb_combo"
	display_name = "Orbe de Combo"
	description = "Atira raios nos inimigos; fica mais forte quanto maior o combo."
	cost = 40
	icon_orb_kind = &"orb_combo"

func is_available() -> bool:
	var manager := _find_manager()
	return manager != null and manager.has_room() and not manager.has_kind(id)

func apply() -> void:
	var manager := _find_manager()
	if manager:
		manager.add_orb(ORB_SCENE.instantiate())

func remove() -> void:
	var manager := _find_manager()
	if manager == null:
		return
	for orb in manager.get_orbs():
		if orb.get_kind_id() == id:
			orb.queue_free()

func _find_manager() -> OrbManager:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.get_first_node_in_group("orb_manager") as OrbManager
