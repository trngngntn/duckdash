extends Skill

var speed: float

func _init():
	mul_atk = 0.75


func _ready() -> void:
	decay_timer = Timer.new()
	decay_timer.one_shot = true
	decay_timer.wait_time = base_decay * mul_decay
	var _d := decay_timer.connect("timeout", self, "_on_decay_timer_timeout")
	add_child(decay_timer)


func trigger(player: Node, _direction: Vector2, _info: AtkInfo, _re_trigger: bool = false) -> void:
	peer_id = player.get_network_master()

	player.get_parent().add_child(self)
	direction = _direction.normalized()
	position = player.position + (_direction.normalized() * Vector2(0.5, 1) * 32)
	position.y -= 26
	$AnimatedSprite.rotation = direction.angle() + PI / 2
	$CollisionPolygon2D.rotation = direction.angle() + PI / 2
	$AnimatedSprite.play("move")
	decay_timer.wait_time *= StatManager.players_stat[peer_id].atk_decay
	decay_timer.start()
	.trigger(player, _direction, _info, _re_trigger)
	scale *= StatManager.players_stat[peer_id].enlargement
	speed = base_speed * mul_speed * StatManager.players_stat[peer_id].proj_speed


func _physics_process(delta) -> void:
	position += direction * delta * speed


func _on_decay_timer_timeout() -> void:
	mul_speed /= 2
	$AnimatedSprite.play("disappear")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "disappear":
		queue_free()
