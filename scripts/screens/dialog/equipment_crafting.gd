extends Control

const TITLE = "CRAFT NEW EQUIPMENT"
var panel_equipment = preload("res://scenes/ui/panel_equipment_info.tscn")

var type_list = []
var current_pos = 0

onready var type_name = $Control/Slot/HBoxContainer/TypeName
onready var cost = $Control/Slot/HBoxContainer/VBoxContainer/HBoxContainer/ItemCount

func _ready():
	for type in Equipment.TYPE.keys():
		type_list.append(type)
	change_type(type_list[0])

	cost.set_item(ItemCount.Item.SOUL)


func change_type(type_id: String):
	type_name.text = Equipment.TYPE[type_id]["display"]
	cost.value = Equipment.TYPE[type_id]["cost"] 


func _on_CraftButton_pressed():
	EquipmentManager.craft_equipment(EquipmentManager.TYPE_SKILL_CASTER)
	var e = yield(EquipmentManager.self_instance, "equipment_crafted")
	var info = panel_equipment.instance()
	info.equipment = e
	add_child(info)


func _on_change_type(added: bool):
	if added:
		current_pos += 1
	else:
		current_pos -= 1

	current_pos %= type_list.size()
	change_type(type_list[current_pos])
