extends Skill


func _init():
	mul_atk = 2
	mul_atk_speed = 3


func _ready():
	tween = Tween.new()
	add_child(tween)


func trigger(player: Node, _direction: Vector2, _info: AtkInfo) -> void:
	rotation = _direction.angle() + PI / 2
	player.add_child(self)
	$AnimatedSprite.play("move")
	tween.interpolate_property($CollisionPolygon2D, "position:y", 0, -4, 0.05)
	tween.start()
	pass


func _on_AnimatedSprite_animation_finished():
	queue_free()
