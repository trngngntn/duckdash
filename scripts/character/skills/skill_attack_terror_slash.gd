extends Skill


func _init():
	mul_atk_speed = 2


func _ready():
	tween = Tween.new()
	var _d = tween.connect("tween_all_completed", self, "_on_tween_all_completed")
	add_child(tween)


func trigger(player: Node, _direction: Vector2, _info: AtkInfo, _re_trigger: bool = false) -> void:
	peer_id = player.get_network_master()

	position.y = -26
	$CollisionPolygon2D.rotation = PI * (13.0 / 18) - _direction.angle()
	$AnimatedSprite.rotation = _direction.angle() + PI / 2
	player.add_child(self)
	$AnimatedSprite.play("move")
	var _d := tween.interpolate_property(
		$CollisionPolygon2D,
		"rotation",
		_direction.angle() + PI / 2 - PI * (4.0 / 18),
		_direction.angle() + PI / 2 + PI * (4.0 / 18),
		0.3
	)
	_d = tween.start()
	.trigger(player, _direction, _info, _re_trigger)


func _on_tween_all_completed():
	queue_free()
