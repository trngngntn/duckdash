extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(Conn.nkm_session)
	if Conn.nkm_session == null:
		ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
		# else:
		# 	$MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/GreetingLabel.text = "Hello, " + Conn.nkm_session.username


func _on_ButtonExit_pressed():
	get_tree().quit()


func _on_ButtonSettings_pressed():
	pass  # Replace with function body.


func _on_ButtonMarketplace_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_MARKETPLACE)


func _on_ButtonInventory_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_INVENTORY)


func _on_ButtonPlay_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_LOBBY)
