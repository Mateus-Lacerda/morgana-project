extends ItemBase
class_name OrbTransformScrollBase


func compute_cost() -> int:
	return EconomyManager.SCROLL_TRANSFORM_COST

## Só aparece quando a orbe alvo já está com os 3 stats no máximo.
func is_available() -> bool:
	var target = _find_target()
	return target != null and target.can_transform()

func apply() -> void:
	var target = _find_target()
	if target:
		target.transform()

## Filhos sobrescrevem: devolvem a orbe específica que esse pergaminho transforma.
func _find_target():
	return null

func _find_manager() -> OrbManager:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.get_first_node_in_group("orb_manager") as OrbManager
