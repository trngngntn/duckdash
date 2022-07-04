extends Control


func _login(email: String, pwd: String) -> void:
	var nkm_session = yield(
		Conn.nkm_client.authenticate_email_async(email, pwd, null, false), "completed"
	)

	if nkm_session.is_exception():
		print("LOGIN_ERR: " + nkm_session.get_exception().message)
		Conn.nkm_session = null
	else:
		Conn.nkm_session = nkm_session
		print("LOGIN_LOG: Logged In!")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


#pressed signal of Login button
func _on_LoginButton_pressed():
	var email: String = $UsernameLineEdit.text
	var pwd: String = $PasswordLineEdit.text
	_login(email, pwd)


func _on_RegisterButton_pressed():
	get_tree().change_scene("res://scenes/screens/sign_up.tscn")
	
func _on_QuitButton_pressed():
	get_tree().quit()
