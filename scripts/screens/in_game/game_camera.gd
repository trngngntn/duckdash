extends Camera2D

var tween: Tween
var tracking_node : Node

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)

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
	print("CAM_TRACK: " + str(node)) 
	tracking_node = node
	if tracking_node.has_method("set_tracking_cam"):
		tracking_node.set_tracking_cam(self)
	tween.start()
