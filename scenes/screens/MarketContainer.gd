extends GridContainer

var selected_listing_item: ListingItem
signal listing_item_selected(item)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_MarketContainer_listing_item_selected(item):
	emit_signal("listing_item_selected", item)
	if selected_listing_item:
		selected_listing_item.unselect()
	selected_listing_item = item
