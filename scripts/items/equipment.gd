extends Node2D
class_name Equipment

var type_name: String setget set_type_name
var sub_type: String
var tier: String
var stat: Array

func set_type_name(_type_name:String) -> void:
    type_name = _type_name