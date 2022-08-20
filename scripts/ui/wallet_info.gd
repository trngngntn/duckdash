extends Panel

signal profile

func _ready():
	set_values()
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return
	$HBoxContainer/NinePatchRect/Username.text = Conn.nkm_session.username
	WalletManager.connect("fetch", self, "set_values")


func set_values() -> void:
	$HBoxContainer/Coin.text = "    " + str(WalletManager.gold) + " "
	$HBoxContainer/Soul.text = "    " + str(WalletManager.soul) + " "


func _on_LinkButton_pressed():
	emit_signal("profile")
