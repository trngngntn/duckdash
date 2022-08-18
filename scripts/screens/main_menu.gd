extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Conn.nkm_session == null:
		ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
	else:
		Conn.connect_nakama_socket()

func _on_ButtonExit_pressed():
	Conn.logout_async()
	
	ScreenManager.screen_res_stack.clear()
	ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
	
func _on_ButtonSettings_pressed():
	pass  # Replace with function body.


func _on_ButtonMarketplace_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_MARKETPLACE)

func _on_ButtonInventory_pressed() -> void:
	ScreenManager.change_screen(ScreenManager.SCREEN_INVENTORY)


func _on_ButtonPlay_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_LOBBY)

func _on_ButtonProfile_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_PROFILE)	
