extends Control
const TITLE = "INVENTORY                                         "

const item = preload("res://scenes/ui/inventory_item.tscn")

signal squeezed

onready var weapon_cont = $TabContainer/Weapon
onready var enhancer_cont = $TabContainer/Enhancer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EquipmentManager.connect("equipment_added", self, "_on_equipment_added")
	for container in $TabContainer.get_children():
		connect("squeezed", container, "_on_squeezed")
	weapon_cont.update_item(EquipmentManager.equipment_list["skill_caster"])
	enhancer_cont.update_item(EquipmentManager.equipment_list["enhancer"])
	weapon_cont.connect("item_selected", self, "_on_item_selected")
	enhancer_cont.connect("item_selected", self, "_on_item_selected")
	weapon_cont.connect("item_cleared", self, "_on_item_cleared")
	enhancer_cont.connect("item_cleared", self, "_on_item_cleared")
	pass


func squeeze() -> void:
	$TabContainer.anchor_right = 0.7
	emit_signal("squeezed")

func unsqueeze() -> void:
	$TabContainer.anchor_right = 1
	emit_signal("squeezed")



func _on_ButtonCraft_pressed() -> void:
	ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_CRAFTING)


func _on_item_selected(item: InventoryItem) -> void:
	squeeze()
	$InfoPanel.show()
	$InfoPanel.set_equipment(item.equipment)


func _on_item_cleared():
	$InfoPanel.hide()
	unsqueeze()


func _on_equipment_added(equipment: Equipment) -> void:
	match equipment.type_name:
		"skill_caster":
			weapon_cont.add_item(equipment)
		"enhancer":
			enhancer_cont.add_item(equipment)


func _on_TabContainer_tab_changed(tab: int):
	$InfoPanel.hide()
	match tab:
		0:
			enhancer_cont.unselect()
		1:
			weapon_cont.unselect()
