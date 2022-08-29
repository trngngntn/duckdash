extends Node2D

var pivot_node: Node2D
var target_node: Node2D

func _process(_delta: float) -> void:
	if is_instance_valid(pivot_node) && is_instance_valid(target_node):
		var vec:Vector2 = (pivot_node.global_position - target_node.global_position)
		$Arrow.rotation = vec.angle()
		position = vec.normalized() * 500
