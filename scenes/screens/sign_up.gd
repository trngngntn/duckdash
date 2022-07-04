extends Control

const ERR_EMAIL_NULL: String = "email_null"
const ERR_EMAIL_EXIST: String = "email_exist"
const ERR_USR_NULL: String = "usr_null"
const ERR_USR_EXIST: String = "Username is already existed."
const ERR_PWD_NULL: String = "pwd_null"
const ERR_CFPWD_NOT_MATCH: String = "Password doesn't match."


func _validate_email() -> void:
	var email: String = $EmailLineEdit.text.strip_edges()
	if email == "":
		$EmailErrorLabel.text = ERR_EMAIL_NULL
	pass


func _validate_usr() -> void:
	var usr: String = $UsernameLineEdit.text.strip_edges()
	if usr == "":
		$UsernameErrorLabel.text = ERR_USR_NULL
	pass


func _validate_pwd() -> void:
	var pwd: String = $PasswordLineEdit.text.strip_edges()
	pass


func _validate_cfpwd() -> void:
	var pwd: String = $PasswordLineEdit.text.strip_edges()
	var cf_pwd: String = $CfPasswordLineEdit.text.strip_edges()
	if cf_pwd != pwd:
		$CfPasswordErrorLabel.text = ERR_CFPWD_NOT_MATCH


func _hide_all_error() -> void:
	$EmailErrorLabel.text = ""
	$UsernameErrorLabel.text = ""
	$PasswordErrorLabel.text = ""
	$CfPasswordErrorLabel.text = ""


func _register(email: String, usr: String, pwd: String) -> void:
	var nkm_session = yield(Conn.nkm_client.authenticate_email_async(email, pwd, usr, true), "completed")

	#check for error (a.k.a. exception) here
	if nkm_session.is_exception():
		var msg = nkm_session.get_exception().message
		if msg == "Invalid credentials.":
			#email is existed
			print("REG_ERR: " + ERR_EMAIL_EXIST)
			pass
		elif msg == "":
			#unknown error
			print("REG_ERR: Unknown")
			pass
		else:
			print("REG_ERR: " + msg)
		Conn.nkm_session = null
	
	else:
		var device_id: String = OS.get_unique_id() + "_duckdash"
		var dev_id_linking: NakamaAsyncResult = yield(Conn.nkm_client.link_device_async(nkm_session, device_id), "completed")
		if dev_id_linking.is_exception():
			print("LINK_DEV_ID_ERR: " + dev_id_linking.get_exception().message)
		else:
			print("LINK_DEV_ID_LOG: Linked!")
		Conn.nkm_session = nkm_session
		print("REG_LOG: Registered!")

	


func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RegisterButton_pressed():
	var email = $EmailLineEdit.text
	var usr = $UsernameLineEdit.text
	var pwd = $PasswordLineEdit.text
	_register(email, usr, pwd)


func _on_BackButton_pressed():
	get_tree().change_scene("res://scenes/screens/sign_in.tscn")
