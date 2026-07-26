extends OrbTransformScrollBase
class_name ScrollTransformComboItem

func _init() -> void:
	id = &"scroll_transform_combo"
	display_name = "ITEM_TRANSFORM_COMBO_NAME"
	description = "ITEM_TRANSFORM_COMBO_DESC"
	cost = EconomyManager.SCROLL_TRANSFORM_COST
	stackable = false
	icon_path = "res://assets/items/scroll_base.png"
	icon_orb_kind = &"orb_combo"

func _find_target():
	var manager := _find_manager()
	if manager == null:
		return null
	for orb in manager.get_orbs():
		if orb.get_kind_id() == &"orb_combo":
			return orb
	return null
