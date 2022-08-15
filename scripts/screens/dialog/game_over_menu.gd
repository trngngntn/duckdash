extends ColorRect


# func _ready():
# 	pause_mode = Node.PAUSE_MODE_PROCESS


func _on_Button_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
