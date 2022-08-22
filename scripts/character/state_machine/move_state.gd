extends DuckState

var direction: Vector2 = Vector2()
var last_direction: Vector2 = Vector2()


func _get_custom_rpc_methods() -> Array:
	return ["_remote_physics_update"]


func init() -> void:
	valid_change = [STATE_IDLE, STATE_DASH, STATE_STABILIZE]
	if player.move_joystick:
		player.move_joystick.connect("active", self, "_on_joystick_active")
	if MatchManager.is_network_master_for_node(self):
		Updater.connect("timeout", self, "_on_update_timeout")


func enter(_dat := {}) -> void:
	pass


func update(_delta) -> void:
	pass


func _remote_physics_update(_direction: Vector2, position: Vector2) -> void:
	direction = _direction
	player.position = position
	update_sprite()


func _on_update_timeout():
	MatchManager.custom_rpc(player, "_force_update", [player.position])


func physics_update(_delta) -> void:
	if not MatchManager.is_network_master_for_node(self):
		player.move_and_slide(direction * StatManager.current_stat.mv_speed)
		return
	if not player.move_joystick:
		direction = Vector2()
		if Input.is_action_pressed("move_up"):
			direction.y -= 1
		if Input.is_action_pressed("move_down"):
			direction.y += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_right"):
			direction.x += 1
	if direction.length() > 0:
		if Input.is_action_just_pressed("move_dash"):
			state_machine.change_state("Dash", {"direction": direction})
			return

		direction = direction.normalized()

		if direction != last_direction:
			last_direction = direction
			MatchManager.custom_rpc(self, "_remote_physics_update", [direction, player.position])
			update_sprite()

		player.move_and_slide(direction * StatManager.current_stat.mv_speed)

	else:
		state_machine.change_state("Idle", {"pos": player.position})


func update_sprite():
	if direction.x > 0:
		player.get_node("AnimatedSprite").play("move_right")
	else:
		player.get_node("AnimatedSprite").play("move_left")


func _on_joystick_active(data: Vector2) -> void:
	direction = data
