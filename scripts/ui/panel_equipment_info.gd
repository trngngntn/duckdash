extends Panel
class_name PanelEquipmentInfo

var equipment: Equipment setget set_equipment

func set_equipment(_equipment: Equipment) -> void:
	equipment = _equipment
	for stat in equipment.stat:
		var label := Label.new()
		print(StatManager.stat_info_list[stat.stat_id]["format"])
		label.text = StatManager.stat_info_list[stat.stat_id]["format"] % stat.value
		$VBoxContainer/StatList.add_child(label)
	

func _ready():
	pass




