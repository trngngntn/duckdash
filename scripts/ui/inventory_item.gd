extends Control
class_name InventoryItem

var equipment: Equipment

var normal_tex = preload("res://assets/sprites/static/ui/ui_item.png")
var selected_tex = preload("res://assets/sprites/static/ui/ui_item_selected.png")

signal selected(item)


func _ready():
	pass  # Replace with function body.

func unselect():
	$NinePatchRect.texture = normal_tex

func _on_InventoryItem_pressed():
	$NinePatchRect.texture = selected_tex
	emit_signal("selected", self)
