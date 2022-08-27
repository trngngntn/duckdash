extends Control
class_name ListingItem

var marketListingItem  setget set_market_listing_item

export var clickable: bool = true

signal selected(item)

var normal_tex = preload("res://assets/sprites/static/ui/ui_item.png")
var selected_tex = preload("res://assets/sprites/static/ui/ui_item_selected.png")

onready var price = $NinePatchRect/HBoxContainer/Price
onready var item = $NinePatchRect/HBoxContainer/Control/InventoryItem

func _ready():
	pass

func unselect():
	$NinePatchRect.texture = normal_tex

func set_market_listing_item(listing_item) -> void:
	marketListingItem = listing_item

func set_properties(listing_item):
	set_market_listing_item(listing_item)
	price.value = listing_item.price

func _on_Node2D_pressed():
	if clickable:
		$NinePatchRect.texture = selected_tex
		emit_signal("selected", marketListingItem)
