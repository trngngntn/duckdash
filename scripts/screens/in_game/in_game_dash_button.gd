extends TouchScreenButton

func _init():
	if not OS.has_touchscreen_ui_hint():
		hide()	


func _on_DashButton_pressed():
	Input.action_press("move_dash")


func _on_DashButton_released():
	Input.action_release("move_dash")
