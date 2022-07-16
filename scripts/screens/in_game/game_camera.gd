extends Camera2D

var tween: Tween
var tracking_node : Node

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)
	tween.start()

func _physics_process(delta) -> void:
	if tracking_node:
		tween.interpolate_property(
			self,
			"position",
			position,
			tracking_node.position,
			delta * 20,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
	

func set_node_tracking(node: Node) -> void:
	tracking_node = node
