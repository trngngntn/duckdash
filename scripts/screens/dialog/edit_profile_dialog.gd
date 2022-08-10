extends Control

const TITLE = "CHANGE USERNAME"
var current_username = null

var LIMIT = 16
var current_text = ""
var cursor_line = 0
var cursor_column = 0

onready var username = get_node("VBoxContainer/UserName")
onready var confirm_dialog = get_node("ConfirmationDialog")

func _ready():
	var account: NakamaAPI.ApiAccount = yield(
		Conn.nkm_client.get_account_async(Conn.nkm_session), "completed"
	)

	if account.is_exception():
		print("An error occurred: %s" % account)
		return

	var user = account.user
	username.text = user.username
	current_username = user.username

func _on_UserName_text_changed():
	var new_text: String = username.text
	if new_text.length() > LIMIT:
		username.text = current_text

		username.cursor_set_line(cursor_line)
		username.cursor_set_column(cursor_column)

	current_text = username.text
	cursor_line = username.cursor_get_line()
	cursor_column = username.cursor_get_column()


func _on_SubmitButton_pressed():
	print(current_username)
	print(username.text)

	if current_username != username.text:
		confirm_dialog.visible = true


func _on_ConfirmationDialog_confirmed():
	var new_username = username.text
	var update: NakamaAsyncResult = yield(
		Conn.nkm_client.update_account_async(Conn.nkm_session, new_username), "completed"
	)

	if update.is_exception():
		print("An error occurred: %s" % update)
		return
