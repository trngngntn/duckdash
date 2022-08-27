extends ScrollContainer

export var min_gap = 10
var item_size = 120

const item_res = preload("res://scenes/ui/listing_item.tscn")

signal listing_selected(item)
signal listing_cleared
var last_selected: ListingItem


func update_item(items: Array) -> void:
	for item in items:
		add_item(item)
	return


func add_item(listing: Listing) -> void:
	var new_item = item_res.instance()
	new_item.connect("selected", self, "_on_listing_selected")
	$VBoxContainer.add_child(new_item)
	new_item.listing = listing

func _on_listing_selected(item: ListingItem) -> void:
	if last_selected:
		last_selected.unselect()
	if last_selected != item:
		emit_signal("listing_selected", item)
		last_selected = item
	else:
		emit_signal("listing_cleared")
		last_selected = null

func unselect() -> void:
	if last_selected:
		emit_signal("listing_cleared")
		last_selected.unselect()
