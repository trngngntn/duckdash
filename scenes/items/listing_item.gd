extends Control
class_name ListingItem

var marketListingItem: MarketListingItem setget set_market_listing_item

export var clickable: bool = true

signal listing_item_selected(item)

var normal_tex = preload("res://assets/sprites/static/ui/ui_item.png")
var selected_tex = preload("res://assets/sprites/static/ui/ui_item_selected.png")

func _ready():
	pass

func set_market_listing_item(eq: MarketListingItem) -> void:
	marketListingItem = eq

func unselect():
	$NinePatchRect.texture = normal_tex

func setProperties(listing_item : MarketListingItem):
	set_market_listing_item(listing_item)
	$NinePatchRect/PriceValue.text = String(listing_item.price)

func _on_Node2D_pressed():
	if clickable:
		$NinePatchRect.texture = selected_tex
		emit_signal("listing_item_selected", marketListingItem)
