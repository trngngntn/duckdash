extends ColorRect

var ok: bool = false


func _ready() -> void:
	WalletManager.connect("error", self, "_on_wallet_update_error")
	WalletManager.connect("updated", self, "_on_wallet_updated")


func show() -> void:
	.show()
	$Panel/ResultCont/Coin.text = str(StatManager.current_stat.coin)
	$Panel/ResultCont/Soul.text = str(StatManager.current_stat.soul)
	update_stat_to_server()


func set_reason(reason: String) -> void:
	$Reason.text = reason


func update_stat_to_server() -> void:
	WalletManager.update_wallet(
		{"gold": StatManager.current_stat.coin, "soul": StatManager.current_stat.soul}
	)
	ok = yield(WalletManager, "update_result")


func _on_wallet_updated() -> void:
	$Panel/Button.text = "OK"


func _on_wallet_update_error(_msg: String) -> void:
	$Panel/Button.text = "Try Again"


func _on_Button_pressed() -> void:
	if ok:
		ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
	else:
		update_stat_to_server()
