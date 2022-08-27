extends Control
const TITLE = "INVENTORY                                         "

const item = preload("res://scenes/ui/inventory_item.tscn")

signal squeezed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EquipmentManager.connect("equipment_added", self, "_on_equipment_added")
	for container in $TabContainer.get_children():
		connect("squeezed", container, "_on_squeezed")
	$TabContainer/Weapon.update_item(EquipmentManager.equipment_list["skill_caster"])
	$TabContainer/Weapon.connect("item_selected", self, "_on_item_selected")
	pass


func squeeze() -> void:
	$TabContainer.anchor_right = 0.7
	emit_signal("squeezed")


func _on_ButtonCraft_pressed() -> void:
	ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_CRAFTING)


func _on_item_selected(item: InventoryItem) -> void:
	squeeze()
	$InfoPanel.show()
	$InfoPanel.set_equipment(item.equipment)


func _on_equipment_added(equipment: Equipment) -> void:
	match equipment.type_name:
		"skill_caster":
			$TabContainer/Weapon.add_item(equipment)
		"shield":
			pass
