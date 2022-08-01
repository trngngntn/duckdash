extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if not NakamaMatch.is_network_server():
		$CollisionPolygon2D.disabled = true


func trigger(player: Node, _direction: Vector2) -> void:
	$CollisionPolygon2D.rotation = PI * (13.0 / 18) - _direction.angle()
	$AnimatedSprite.rotation = _direction.angle() + PI / 2
	player.add_child(self)
	$AnimatedSprite.play("move")
	$Tween.interpolate_property(
		$CollisionPolygon2D,
		"rotation",
		_direction.angle() + PI / 2 - PI * (4.0 / 18),
		_direction.angle() + PI / 2 + PI * (4.0 / 18),
		0.3
	)
	# $Tween.interpolate_property($CollisionPolygon2D, "rotation",PI, 0, 1)
	$Tween.start()
	pass


func _on_Tween_tween_all_completed():
	queue_free()


func _on_Area2D_area_entered(area: Area2D):
	var node = area.get_parent()
	if node is Enemy:
		NakamaMatch.custom_rpc_sync(node, "hurt")
