extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if Conn.nkm_session == null:
		ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
	else:
		$GreetingRichTextLabel.text = "Hello, " + Conn.nkm_session.username


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_LOBBY)


func _on_InventoryButton_pressed():
	pass # Replace with function body.


func _on_MarketplaceButton_pressed():
	pass # Replace with function body.


func _on_QuitButton_pressed():
	get_tree().quit()
