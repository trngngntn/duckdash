extends DuckState


func enter(_dat := {}) -> void:
	if player.joystick:
		player.joystick.connect("active", self, "_on_joystick_active")
	player.get_node("AnimatedSprite").play("idle_right")
	#player.velocity = Vector2(0,0)


func update(_delta: float) -> void:
	if (
		Input.is_action_pressed("move_up")
		|| Input.is_action_pressed("move_down")
		|| Input.is_action_pressed("move_left")
		|| Input.is_action_pressed("move_right")
	):
		state_machine.change_state("Move", {})

func _on_joystick_active(data: Vector2) -> void:
	if data.length() > 0:
		state_machine.change_state("Move", {})
