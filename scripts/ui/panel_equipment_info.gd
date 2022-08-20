extends Panel
class_name PanelEquipmentInfo

var equipment: Equipment setget set_equipment
var font = preload("res://resources/font/ui_font_small.tres")


func set_equipment(_equipment: Equipment) -> void:
	for child in $ScrollContainer/VBoxContainer/StatList.get_children():
		$ScrollContainer/VBoxContainer/StatList.remove_child(child)

	equipment = _equipment

	$ScrollContainer/VBoxContainer/Name.text = Equipment.TYPE[equipment.type_name]["display"]

	var label := Label.new()
	label.set("custom_fonts/font", font)
	# label.text = "Tier: " + equipment.tier
	if equipment.sub_type && equipment.sub_type != "":
		label.text = equipment.SUB_TYPE[equipment.sub_type]["name"]
		label.align = Label.ALIGN_CENTER
	$ScrollContainer/VBoxContainer/StatList.add_child(label)

	$ScrollContainer/VBoxContainer/Control/InventoryItem.equipment = equipment

	for stat in equipment.stat:
		label = Label.new()
		label.set("custom_fonts/font", font)
		label.text = StatManager.stat_info_list[stat.stat_id]["format"] % stat.value
		$ScrollContainer/VBoxContainer/StatList.add_child(label)

	if EquipmentManager.is_equipped(equipment):
		$EquipButton.hide()
	else:
		$EquipButton.show()


func _ready():
	# font = DynamicFont.new()
	# font.font_data = load("res://resources/font/ui_font_small.tres")
	pass


func _on_EquipButton_pressed():
	EquipmentManager.equip(equipment)
	$EquipButton.hide()
