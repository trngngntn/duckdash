extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Conn.nkm_session)
	if Conn.nkm_session == null:
		ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
	else:
		$MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/GreetingLabel.text = "Hello, " + Conn.nkm_session.username


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_LOBBY)


func _on_InventoryButton_pressed():
	ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_CRAFTING)


func _on_MarketplaceButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_MARKETPLACE)


func _on_QuitButton_pressed():
	get_tree().quit()
