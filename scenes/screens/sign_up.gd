extends Control

const ERR_EMAIL_NULL: String = "email_null"
const ERR_EMAIL_EXIST: String = "email_exist"
const ERR_USR_NULL: String = "usr_null"
const ERR_USR_EXIST: String = "Username is already existed."
const ERR_PWD_NULL: String = "pwd_null"
const ERR_CFPWD_NOT_MATCH: String = "Password doesn't match."


func _hide_all_error() -> void:
	$EmailErrorLabel.text = ""
	$UsernameErrorLabel.text = ""
	$PasswordErrorLabel.text = ""
	$CfPasswordErrorLabel.text = ""



func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RegisterButton_pressed():
	var email = $EmailLineEdit.text
	var usr = $UsernameLineEdit.text
	var pwd = $PasswordLineEdit.text
	Conn.register_async(email, usr, pwd)


func _on_BackButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
