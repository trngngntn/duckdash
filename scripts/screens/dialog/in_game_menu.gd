extends ColorRect


func _get_custom_rpc_methods() -> Array:
	return [
		"player_exit",
	]


# func _ready():
# 	pause_mode = Node.PAUSE_MODE_PROCESS


func player_exit() -> void:
	MatchManager.current_match.stop_game(InGame.REASON_PLAYER_EXIT)


func _on_ExitButton_pressed():
	MatchManager.custom_rpc(self, "player_exit")
	MatchManager.current_match.stop_game(InGame.REASON_EXIT)


func _on_ResumeButton_pressed():
	hide()
	if MatchManager.match_mode == MatchManager.MatchMode.SINGLE:
		get_tree().paused = false
