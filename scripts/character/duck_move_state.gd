extends DuckState

func enter(_dat := {}) -> void:
	pass

func physics_update(_delta) -> void:
	var direction = Vector2()
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
	else:
		state_machine.change_state("Idle", {})
