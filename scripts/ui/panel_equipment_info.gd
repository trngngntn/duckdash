extends Panel
class_name PanelEquipmentInfo

var equipment: Equipment setget set_equipment
var font = preload("res://resources/font/ui_font_small.tres")


func set_equipment(_equipment: Equipment) -> void:
	for child in $VBoxContainer/StatList.get_children():
		$VBoxContainer/StatList.remove_child(child)

	equipment = _equipment
	for stat in equipment.stat:
		var label := Label.new()
		label.set("custom_fonts/font", font)
		label.text = StatManager.stat_info_list[stat.stat_id]["format"] % stat.value
		$VBoxContainer/StatList.add_child(label)


func _ready():
	# font = DynamicFont.new()
	# font.font_data = load("res://resources/font/ui_font_small.tres")
	pass
