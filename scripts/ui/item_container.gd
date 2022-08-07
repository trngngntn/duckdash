extends ScrollContainer

export var min_gap = 10
var item_size = 120

const item_res = preload("res://scenes/ui/inventory_item.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(),"idle_frame")
	var item_col = floor((rect_size.x - 20) / (min_gap + item_size))
	var gap = ((rect_size.x - 20) - item_col * item_size) / (item_col - 1)
	$GridContainer.columns = item_col
	print("COLL: " + str(rect_size))
	$GridContainer.add_constant_override("hseparation",gap)
	$GridContainer.add_constant_override("vseparation",gap)
	for i in range(1,100):
		$GridContainer.add_child(item_res.instance())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
