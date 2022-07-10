extends DuckState


func enter(_dat := {}) -> void:
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
