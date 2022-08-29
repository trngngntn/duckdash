class_name Equipment

const TYPE = {
	"skill_caster": {"display": "Skill Caster", "cost": 2000},
	"enhancer": {"display": "Enhancer", "cost": 1000}
}

var raw: String
var type_name: String setget set_type_name
var sub_type: String
var tier: String setget set_tier, get_tier
var stat: Array

signal list


func set_type_name(_type_name: String) -> void:
	type_name = _type_name


func set_tier(_tier: String) -> void:
	tier = _tier


func get_tier() -> String:
	if not tier || tier == "":
		return "BASIC"
	else:
		return tier


func list():
	emit_signal("list")
	EquipmentManager.equipment_list[type_name].erase(self)
	EquipmentManager.equipped[type_name].erase(self)
