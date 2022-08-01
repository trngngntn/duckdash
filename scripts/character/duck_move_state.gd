extends DuckState

var _move_direction: Vector2
var direction = Vector2()


func _get_custom_rpc_methods() -> Array:
	return ["_remote_physics_update"]


func init() -> void:
	if player.move_joystick:
		player.move_joystick.connect("active", self, "_on_joystick_active")


func enter(_dat := {}) -> void:
	pass


func update(_delta) -> void:
	pass


func _remote_physics_update(_direction: Vector2, position: Vector2) -> void:
	direction = _direction
	player.position = position
	update_sprite()

func physics_update(_delta) -> void:
	if not NakamaMatch.is_network_master_for_node(self):
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
		update_sprite()
		# player.move_and_slide(direction * player.speed, Vector2(0,0), false, 4, 0.785398, false)
		player.move_and_slide(direction * player.speed)
		NakamaMatch.custom_rpc(self, "_remote_physics_update", [direction, player.position])
	else:
		state_machine.change_state("Idle", {})

func update_sprite():
	if direction.x > 0:
		player.get_node("AnimatedSprite").play("move_right")
	else:
		player.get_node("AnimatedSprite").play("move_left")

func _on_joystick_active(data: Vector2) -> void:
	direction = data
