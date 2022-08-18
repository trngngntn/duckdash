extends ColorRect

# func _ready():
# 	pause_mode = Node.PAUSE_MODE_PROCESS

func show() -> void:
	.show()
	$Panel/ResultCont/Coin.text = str(StatManager.current_stat.coin)
	$Panel/ResultCont/Soul.text = str(StatManager.current_stat.soul)


func set_reason(reason: String) -> void:
	$Reason.text = reason


func _on_Button_pressed() -> void:
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
