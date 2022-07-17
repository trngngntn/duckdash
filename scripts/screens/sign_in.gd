extends Control

const TITLE = "SIGN IN"


# Called when the node enters the scene tree for the first time.
func _ready():
	var error_code = Conn.connect("nakama_logged_in", self, "_on_logged_in")
	if error_code != 0:
		print("SCREEN_LOGIN_ERROR: ", error_code)


#pressed signal of Login button
func _on_LoginButton_pressed():
	var email: String = $VBoxContainer/UsernameLineEdit.text
	var pwd: String = $VBoxContainer/PasswordLineEdit.text
	Conn.login_async(email, pwd)


func _on_logged_in() -> void:
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_SignUpButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_REGISTER)
