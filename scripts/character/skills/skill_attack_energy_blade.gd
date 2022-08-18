extends Skill


func _ready() -> void:
	mul_atk = 0.75

	decay_timer = Timer.new()
	decay_timer.one_shot = true
	decay_timer.wait_time = base_decay * mul_decay
	var _d := decay_timer.connect("timeout", self, "_on_decay_timer_timeout")
	add_child(decay_timer)


func trigger(player: Node, _direction: Vector2, _info: AtkInfo) -> void:
	player.get_parent().add_child(self)
	direction = _direction.normalized()
	position = player.position + (_direction.normalized() * Vector2(0.5, 1) * 32)
	$AnimatedSprite.rotation = direction.angle() + PI / 2
	$CollisionPolygon2D.rotation = direction.angle() + PI / 2
	$AnimatedSprite.play("move")
	decay_timer.start()


func _physics_process(delta) -> void:
	position += direction * delta * base_speed * mul_speed


func _on_decay_timer_timeout() -> void:
	mul_speed /= 2
	$AnimatedSprite.play("disappear")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "disappear":
		queue_free()
