extends OrbTransformScrollBase
class_name ScrollTransformBladeItem

func _init() -> void:
	id = &"scroll_transform_blade"
	display_name = "Transformação — Lâmina Giratória"
	description = "A lâmina cresce bastante e passa a perseguir o morcego gigante mais próximo."
	cost = TRANSFORM_COST
	stackable = false
	icon_path = "res://assets/items/scroll_base.png"
	icon_orb_kind = &"orb_blade"

func _find_target():
	var manager := _find_manager()
	if manager == null:
		return null
	for orb in manager.get_orbs():
		if orb.get_kind_id() == &"orb_blade":
			return orb
	return null
