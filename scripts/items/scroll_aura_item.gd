extends EvolutionScrollBase
class_name ScrollAuraItem

func _init() -> void:
	id = &"scroll_aura"
	display_name = "ITEM_SCROLL_AURA_NAME"
	description = "ITEM_SCROLL_AURA_DESC"
	cost = EconomyManager.SCROLL_BASE_COST
	stackable = true
	icon_path = "res://assets/items/scroll_base.png"
	icon_overlay_path = "res://assets/items/aura_icon.png"

func _find_target():
	var player := _find_player()
	if player and player.aura_ability.unlocked:
		return player.aura_ability
	return null
