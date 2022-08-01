extends DuckState

func init() -> void:
	if player.move_joystick && NakamaMatch.is_network_master_for_node(self):
		player.move_joystick.connect("active", self, "_on_joystick_active")
		
func enter(_dat := {}) -> void:
	player.get_node("AnimatedSprite").play("idle_right")
	#player.velocity = Vector2(0,0)


func physics_update(_delta: float) -> void:
	if not NakamaMatch.is_network_master_for_node(self):
		return
	if not player.move_joystick:	
		if (
			Input.is_action_pressed("move_up")
			|| Input.is_action_pressed("move_down")
			|| Input.is_action_pressed("move_left")
			|| Input.is_action_pressed("move_right")
		):
			state_machine.change_state("Move", {})

func _on_joystick_active(data: Vector2) -> void:
	if data.length() > 0 && state_machine.state.name != "Dash":
		state_machine.change_state("Move", {})
