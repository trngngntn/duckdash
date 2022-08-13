extends Camera2D

var tween: Tween
var tracking_node : Node
var set: bool = false

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)

func _physics_process(delta) -> void:
	if set && (not is_instance_valid(tracking_node) || tracking_node.is_queued_for_deletion()):
		queue_free()
		return
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
	set = true
	# if tracking_node.has_method("set_tracking_cam"):
	# 	tracking_node.set_tracking_cam(self)
	tween.start()
