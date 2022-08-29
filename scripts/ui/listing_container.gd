extends ScrollContainer

export var min_gap = 10
var item_size = 120

const item_res = preload("res://scenes/ui/listing_item.tscn")

signal listing_selected(item)
signal listing_cleared
var last_selected: ListingItem


func update_listing(lisitngs: Array) -> void:
	for listing in lisitngs:
		add_listing(listing)


func add_listing(listing: Listing) -> void:
	var new_item = item_res.instance()
	new_item.connect("selected", self, "_on_listing_selected")
	new_item.connect("unselected", self, "unselect")
	$VBoxContainer.add_child(new_item)
	new_item.listing = listing


func _on_listing_selected(item: ListingItem) -> void:
	if is_instance_valid(last_selected):
		last_selected.unselect()
	if last_selected != item:
		emit_signal("listing_selected", item)
		last_selected = item
	else:
		emit_signal("listing_cleared")
		last_selected = null


func unselect(_listing = null) -> void:
	if last_selected:
		emit_signal("listing_cleared")
		if is_instance_valid(last_selected):
			last_selected.unselect()
