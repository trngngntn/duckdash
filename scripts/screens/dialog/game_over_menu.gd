extends ColorRect

# func _ready():
# 	pause_mode = Node.PAUSE_MODE_PROCESS

func show() -> void:
	.show()
	$Panel/ResultCont/Coin.text = str(StatManager.current_stat.coin)
	$Panel/ResultCont/Soul.text = str(StatManager.current_stat.soul)
	update_stat_to_server()

func set_reason(reason: String) -> void:
	$Reason.text = reason

func update_stat_to_server() -> void:
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		print("[LOG][GOVER]Renew session")
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			print("[LOG][GOVER]Null session")
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
			return
		print("[LOG][GOVER]Updating result")

	var payload = {"gold": StatManager.current_stat.coin, "soul": StatManager.current_stat.soul}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "update_wallet", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		print("An error occurred: %s" % response)
		NotificationManager.show_custom_notification("Error", "Can not update result to server!")
		$Panel/Button.text = "Try Again"
		return null
	print("[LOG][GOVER]Result updated")
	$Panel/Button.text = "OK"

func _on_Button_pressed() -> void:
	if $Panel/Button.text == "OK":
		ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
	else: 
		update_stat_to_server()
