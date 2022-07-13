extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var error_code = Conn.connect("nakama_logged_in",self,"_on_logged_in")
	if error_code != 0:
		print("SCREEN_LOGIN_ERROR: ", error_code)

#pressed signal of Login button
func _on_LoginButton_pressed():
	var email: String = $UsernameLineEdit.text
	var pwd: String = $PasswordLineEdit.text
	Conn.login_async(email, pwd)

func _on_logged_in() -> void:
	print("Logged, change scene")
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)

func _on_RegisterButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_REGISTER)
	# get_tree().current_scene.change_screen(ScreenManager.SCREEN_REGISTER)
	
func _on_QuitButton_pressed():
	get_tree().quit()

