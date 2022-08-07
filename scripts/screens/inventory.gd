extends Control
const TITLE = "INVENTORY"

const item = preload("res://scenes/ui/inventory_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# for i in range(0, 100):
	# 	$TabContainer/Weapon/Container.add_child(item.instance())
	pass




func _on_ButtonCraft_pressed():
	ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_CRAFTING)
