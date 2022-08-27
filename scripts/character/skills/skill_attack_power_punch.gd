extends Skill


func _init():
	mul_atk = 2
	mul_atk_speed = 3


func _ready():
	tween = Tween.new()
	add_child(tween)


func trigger(player: Node, _direction: Vector2, _info: AtkInfo, _re_trigger: bool = false) -> void:
	peer_id = player.get_network_master()

	position.y = -26
	$AnimatedSprite.rotation = _direction.angle() + PI / 2
	$CollisionPolygon2D.rotation = $AnimatedSprite.rotation
	player.add_child(self)
	$AnimatedSprite.play("move")
	tween.interpolate_property(
		$CollisionPolygon2D,
		"position",
		null,
		Vector2(0, -10).rotated($AnimatedSprite.rotation),
		0.05
	)
	tween.start()
	.trigger(player, _direction, _info, _re_trigger)


func _on_AnimatedSprite_animation_finished():
	queue_free()
