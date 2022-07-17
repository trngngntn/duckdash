extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_LeaveButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
