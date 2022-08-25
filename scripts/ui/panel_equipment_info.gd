extends Panel
class_name PanelEquipmentInfo

const FONT_TIER_BASIC = {
	"res": preload("res://resources/font/ui_font_tier_0.tres"), "color": Color("566c86")
}
const FONT_TIER_COMMON = {
	"res": preload("res://resources/font/ui_font_tier_1.tres"), "color": Color("f4f4f4")
}
const FONT_TIER_UNCOMMON = {
	"res": preload("res://resources/font/ui_font_tier_2.tres"), "color": Color("91f25a")
}
const FONT_TIER_RARE = {
	"res": preload("res://resources/font/ui_font_tier_3.tres"), "color": Color("3b5dc9")
}
const FONT_TIER_EPIC = {
	"res": preload("res://resources/font/ui_font_tier_4.tres"), "color": Color("b328b3")
}
const FONT_TIER_LEGENDARY = {
	"res": preload("res://resources/font/ui_font_tier_5.tres"), "color": Color("ffcb00")
}

var equipment: Equipment setget set_equipment
var font = preload("res://resources/font/ui_font_small.tres")

onready var eq_name = $ScrollContainer/VBoxContainer/Name


func set_equipment(_equipment: Equipment) -> void:
	for child in $ScrollContainer/VBoxContainer/StatList.get_children():
		$ScrollContainer/VBoxContainer/StatList.remove_child(child)

	equipment = _equipment

	eq_name.set("custom_fonts/font", get("FONT_TIER_" + equipment.tier)["res"])
	eq_name.set("custom_colors/font_color", get("FONT_TIER_" + equipment.tier)["color"])
	eq_name.text = Equipment.TYPE[equipment.type_name]["display"]

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
