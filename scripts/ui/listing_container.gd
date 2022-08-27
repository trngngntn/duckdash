extends ScrollContainer

export var min_gap = 10
var item_size = 120

const item_res = preload("res://scenes/ui/listing_item.tscn")

signal item_selected(item)

var last_selected: Listing


func update_item(items: Array) -> void:
	for item in items:
		add_item(item)
	return


func add_item(item: Listing) -> void:
	var new_item = item_res.instance()
	new_item.connect("selected", self, "_on_item_selected")
	$VBoxContainer.add_child(new_item)
	new_item.set_properties(item)


func _on_item_selected(item: Listing) -> void:
	emit_signal("item_selected", item)
	if last_selected:
		last_selected.unselect()
	last_selected = item
