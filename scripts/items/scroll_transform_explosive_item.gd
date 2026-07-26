extends OrbTransformScrollBase
class_name ScrollTransformExplosiveItem

func _init() -> void:
	id = &"scroll_transform_explosive"
	display_name = "ITEM_TRANSFORM_EXPLOSIVE_NAME"
	description = "ITEM_TRANSFORM_EXPLOSIVE_DESC"
	cost = EconomyManager.SCROLL_TRANSFORM_COST
	stackable = false
	icon_path = "res://assets/items/scroll_base.png"
	icon_orb_kind = &"orb_explosive"

func _find_target():
	var manager := _find_manager()
	if manager == null:
		return null
	for orb in manager.get_orbs():
		if orb.get_kind_id() == &"orb_explosive":
			return orb
	return null
