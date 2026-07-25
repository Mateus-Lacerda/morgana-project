extends OrbTransformScrollBase
class_name ScrollTransformExplosiveItem

func _init() -> void:
	id = &"scroll_transform_explosive"
	display_name = "Transformação — Orbe Explosiva"
	description = "Vira um molotov mágico: a explosão deixa uma área em chamas que continua causando dano."
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
