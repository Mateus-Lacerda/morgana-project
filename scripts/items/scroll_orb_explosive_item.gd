extends EvolutionScrollBase
class_name ScrollOrbExplosiveItem

func _init() -> void:
	id = &"scroll_orb_explosive"
	display_name = "ITEM_SCROLL_EXPLOSIVE_NAME"
	description = "ITEM_SCROLL_EXPLOSIVE_DESC"
	cost = EconomyManager.SCROLL_BASE_COST
	stackable = true
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
