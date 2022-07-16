extends DuckState

var _move_direction: Vector2
var direction = Vector2()

func _get_custom_rpc_methods() -> Array:
	return ["_remote_physics_update"]

func init() -> void:
	if player.joystick:
		player.joystick.connect("active", self, "_on_joystick_active")

func enter(_dat := {}) -> void:
	pass

func _remote_physics_update(direction) -> void:
	player.move_and_slide(direction * player.speed)

func update(_delta) -> void:
	pass

func physics_update(_delta) -> void:
	if OS.get_name() != "Android":
		direction = Vector2()
		if Input.is_action_pressed("move_up"):
			direction.y -= 1
		if Input.is_action_pressed("move_down"):
			direction.y += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_right"):
			direction.x += 1

	if Input.is_action_just_pressed("move_dash"):
		state_machine.change_state("Dash", {"direction": direction})
		return

	if direction.length() > 0:
		if direction.x > 0:
			player.get_node("AnimatedSprite").play("move_right")
		else:
			player.get_node("AnimatedSprite").play("move_left")
		direction = direction.normalized()
		player.move_and_slide(direction * player.speed)
		NakamaMatch.custom_rpc(self, "_remote_physics_update", [direction])
	else:
		state_machine.change_state("Idle", {})


func _on_joystick_active(data: Vector2) -> void:
	direction = data
