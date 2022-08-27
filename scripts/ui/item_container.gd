extends ScrollContainer

export var min_gap = 10
var item_size = 120

const item_res = preload("res://scenes/ui/inventory_item.tscn")

signal item_selected(item)

var last_selected: InventoryItem


func _ready():
	_update_sizing()


func update_item(items: Array) -> void:
	for equipment in items:
		add_item(equipment)
	return


func add_item(item: Equipment) -> void:
	var new_item = item_res.instance()
	new_item.equipment = item
	new_item.connect("selected", self, "_on_item_selected")
	$Margin/GridContainer.add_child(new_item)


func _update_sizing() -> void:
	yield(get_tree(), "idle_frame")
	var item_col = floor((rect_size.x - 40) / (min_gap + item_size))
	var gap = ((rect_size.x - 40) - item_col * item_size) / (item_col - 1)
	$Margin/GridContainer.columns = item_col
	# print("COLL: " + str(rect_size))
	$Margin/GridContainer.add_constant_override("hseparation", gap)
	$Margin/GridContainer.add_constant_override("vseparation", gap)


func _on_squeezed() -> void:
	_update_sizing()


func _on_item_selected(item: InventoryItem) -> void:
	emit_signal("item_selected", item)
	if last_selected:
		last_selected.unselect()
	last_selected = item
