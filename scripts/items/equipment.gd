class_name Equipment



var raw: String
var type_name: String setget set_type_name
var sub_type: String
var tier: String setget set_tier, get_tier
var stat: Array

func set_type_name(_type_name: String) -> void:
	type_name = _type_name


func set_tier(_tier: String) -> void:
	tier = _tier


func get_tier() -> String:
	if not tier || tier == "":
		return "BASIC"
	else:
		return tier
