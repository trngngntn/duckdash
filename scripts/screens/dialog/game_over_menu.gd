extends ColorRect

# func _ready():
# 	pause_mode = Node.PAUSE_MODE_PROCESS


func set_reason(reason: String) -> void:
	$Reason.text = reason


func _on_Button_pressed() -> void:
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
