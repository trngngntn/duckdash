extends Control
const TITLE = "SELECT EQUIPMENT"

func set_type(type: String) -> void:
	$ItemContainer.update_item(EquipmentManager.equipment_list[type])

func _on_ItemContainer_item_selected(item):
	$InfoPanel.set_equipment(item.equipment)
	
	

