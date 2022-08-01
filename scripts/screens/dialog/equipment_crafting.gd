extends Control

const TITLE = "CRAFT NEW EQUIPMENT"
var panel_equipment = preload("res://scenes/ui/panel_equipment_info.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CraftButton_pressed():
	EquipmentManager.craft_equipment(EquipmentManager.TYPE_SKILL_CASTER)
	var e = yield(EquipmentManager.self_instance, "equipment_crafted")
	var info = panel_equipment.instance()
	info.equipment = e
	add_child(info)