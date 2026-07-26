extends EvolutionScrollBase
class_name ScrollWandItem

func _init() -> void:
	id = &"scroll_wand"
	display_name = "ITEM_SCROLL_WAND_NAME"
	description = "ITEM_SCROLL_WAND_DESC"
	cost = EconomyManager.SCROLL_BASE_COST
	stackable = true
	icon_path = "res://assets/items/scroll_base.png"
	icon_overlay_path = "res://assets/items/wand_icon.png"

func _find_target():
	var player := _find_player()
	if player and player.wand_ability.unlocked:
		return player.wand_ability
	return null
