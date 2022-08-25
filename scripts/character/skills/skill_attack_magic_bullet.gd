extends Skill

var target_count: int = 0


func _get_custom_rpc_methods() -> Array:
	return ["_decay"]


func _init():
	mul_speed = 3.25
	mul_atk = 1.5
	mul_atk_speed = 4


func _ready() -> void:
	decay_timer = Timer.new()
	decay_timer.one_shot = true
	decay_timer.wait_time = base_decay * mul_decay
	var _d := decay_timer.connect("timeout", self, "_on_decay_timer_timeout")
	add_child(decay_timer)


func trigger(player: Node, _direction: Vector2, _info: AtkInfo, _re_trigger := false) -> void:
	peer_id = player.get_network_master()

	direction = _direction.normalized()
	position = player.position + (direction * Vector2(0.5, 1) * 32)
	position.y -= 26
	$AnimatedSprite.rotation = direction.angle() + PI / 2
	$AnimatedSprite.play("move")

	player.get_parent().add_child(self)
	decay_timer.start()
	.trigger(player, _direction, _info, _re_trigger)


func _physics_process(delta) -> void:
	position += direction * delta * base_speed * mul_speed


func _on_decay_timer_timeout() -> void:
	mul_speed = 0
	$AnimatedSprite.play("disappear")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "disappear":
		queue_free()


func _decay() -> void:
	decay_timer.stop()
	_on_decay_timer_timeout()


func _on_Area2D_area_entered(area: Area2D):
	var node = area.get_parent()
	if target_count <= StatManager.current_stat.proj_pierce:
		if node is Enemy:
			MatchManager.custom_rpc_sync(node, "hurt", [gen_atk_info().to_dict()])
			target_count += 1
	if target_count > StatManager.current_stat.proj_pierce:
		MatchManager.custom_rpc_sync(self, "_decay")
