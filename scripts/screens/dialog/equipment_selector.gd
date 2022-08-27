extends Control
const TITLE = "SELECT EQUIPMENT"

# func _ready():
# 	# $InfoPanel.rect_position.x += $InfoPanel.rect_size.x

func set_type(type: String) -> void:
	$ItemContainer.update_item(EquipmentManager.equipment_list[type])

func _on_ItemContainer_item_selected(item):
	$InfoPanel.show()
	$ItemContainer.anchor_right = 0.7
	$ItemContainer._update_sizing()
	$InfoPanel.set_equipment(item.equipment)
	
	

