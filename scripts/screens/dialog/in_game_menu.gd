extends ColorRect

func _ready():
	pass # Replace with function body.



func _on_ExitButton_pressed():
	MatchManager.stop_game()

func _on_ResumeButton_pressed():
	hide() 	
