extends Node

signal error(msg)
signal updated
signal update_result(success)

signal fetch

var gold: int
var soul: int


func _ready():
	Conn.connect("session_connected", self, "fetch_wallet")
	Conn.connect("notif_wallet_updated", self, "_on_wallet_updated")


func fetch_wallet(_session) -> void:
	var account: NakamaAPI.ApiAccount = yield(
		Conn.nkm_client.get_account_async(Conn.nkm_session), "completed"
	)
	var wallet = JSON.parse(account.wallet).result
	# print(wallet)
	gold = wallet["gold"]
	soul = wallet["soul"]
	emit_signal("fetch")


func update_wallet(changeset: Dictionary) -> void:
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		# print("[LOG][WALLET]Renew session")
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			# print("[LOG][WALLET]Null session")
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return
			# print("[LOG][GOVER]Updating result")

	var payload = changeset
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "update_wallet", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		print("An error occurred: %s" % response)
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		emit_signal("error", response.get_exception().message)
		emit_signal("update_result", false)
	emit_signal("updated")
	emit_signal("update_result", true)
	print("[LOG][WALLET]Updated")

func _on_wallet_updated(content: String) -> void:
	var wallet = JSON.parse(content).result
	gold = wallet["gold"]
	soul = wallet["soul"]
	emit_signal("fetch")
