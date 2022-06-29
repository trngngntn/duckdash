extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_BackButton_pressed():
	print("Hello")
	get_tree().change_scene("res://scenes/screens/sign_in.tscn")

func _on_LogoutButton_pressed():
	if Conn.nkm_session:
		yield(Conn.get_nakama_client().session_logout_async(Conn.nkm_session), "completed")
