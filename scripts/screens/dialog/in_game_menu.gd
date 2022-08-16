extends ColorRect


# func _ready():
# 	pause_mode = Node.PAUSE_MODE_PROCESS


func _on_ExitButton_pressed():
	MatchManager.current_match.stop_game()


func _on_ResumeButton_pressed():
	hide()
	if MatchManager.match_mode == MatchManager.MatchMode.SINGLE:
		get_tree().paused = false
