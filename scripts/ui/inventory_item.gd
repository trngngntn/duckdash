extends Control
class_name InventoryItem

var equipment: Equipment setget set_equipment

export var clickable: bool = true

var normal_tex = preload("res://assets/sprites/static/ui/ui_item.png")
var selected_tex = preload("res://assets/sprites/static/ui/ui_item_selected.png")

signal selected(item)


func _ready():
	pass  # Replace with function body.


func set_equipment(eq: Equipment) -> void:
	equipment = eq
	$NinePatchRect/TextureRect.texture = eq.TEX[0]


func unselect():
	$NinePatchRect.texture = normal_tex


func _on_InventoryItem_pressed():
	if clickable:
		$NinePatchRect.texture = selected_tex
		emit_signal("selected", self)
