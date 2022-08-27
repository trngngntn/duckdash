extends Control
class_name ListingItem

var listing: Listing  setget set_listing

export var clickable: bool = true

signal selected(item)

var normal_tex = preload("res://assets/sprites/static/ui/ui_item.png")
var selected_tex = preload("res://assets/sprites/static/ui/ui_item_selected.png")

onready var price = $NinePatchRect/HBoxContainer/Price
onready var item = $NinePatchRect/HBoxContainer/Control/InventoryItem
onready var eq_name = $NinePatchRect/HBoxContainer/Name

func _ready():
	pass

func unselect():
	$NinePatchRect.texture = normal_tex

func set_listing(_listing) -> void:
	listing = _listing

	var equipment = listing.equipment

	eq_name.set("custom_fonts/font", PanelEquipmentInfo.FONT_TIER_LIST[equipment.tier]["res"])
	eq_name.set("custom_colors/font_color", PanelEquipmentInfo.FONT_TIER_LIST[equipment.tier]["color"])
	eq_name.text = Equipment.TYPE[equipment.type_name]["display"]


	price.value = listing.price
	$NinePatchRect/HBoxContainer/Control/InventoryItem.equipment = listing.equipment

# func set_properties(_listing_item):
# 	set_market_listing_item(_listing_item)
# 	price.value = listing_item.price

func _on_Node2D_pressed():
	if clickable:
		$NinePatchRect.texture = selected_tex
		emit_signal("selected", self)
