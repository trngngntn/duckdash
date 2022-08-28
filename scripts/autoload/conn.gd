extends Node

onready var self_instance = self

var nkm_server_key: String = "duckdash_nakama"
# var nkm_host: String = "10.144.0.2"
var nkm_host: String = "minorcircus.duckdns.org"
var nkm_port: int = 7350
var nkm_scheme: String = "http"

enum NotificationCode {
	WALLET_UPDATED = 10,
	RESERVED = 0,
	FRIEND_REQUEST_RECEIVED = -2,
	FRIEND_REQUEST_ACCEPTED = -3,
}

#Nakama client
var nkm_client: NakamaClient setget _set_readonly_var, get_nakama_client


func _set_readonly_var(_value) -> void:
	pass


func get_nakama_client() -> NakamaClient:
	if nkm_client == null:
		nkm_client = Nakama.create_client(
			nkm_server_key,
			nkm_host,
			nkm_port,
			nkm_scheme,
			Nakama.DEFAULT_TIMEOUT,
			NakamaLogger.LOG_LEVEL.ERROR
		)
		nkm_client.timeout = 300
	return nkm_client


#Nakama session
var nkm_session: NakamaSession setget set_nakama_session
signal session_changed(nkm_session)
signal session_connected(nkm_session)


func set_nakama_session(_nkm_session: NakamaSession) -> void:
	# Close out the old socket.
	if nkm_socket:
		nkm_socket.close()
		nkm_socket = null

	nkm_session = _nkm_session

	emit_signal("session_changed", nkm_session)

	if nkm_session && not nkm_session.is_exception() && not nkm_session.is_expired():
		print("[LOG][CONN]Session connected")
		emit_signal("session_connected", nkm_session)


func renew_session() -> NakamaSession:
	if nkm_session == null || nkm_session.is_expired():
		device_auth(true)
		print("[LOG][NKM_SESSION] Renewing session")
		var dev: bool = yield(self, "dev_auth_finished")
		if not dev:
			print("[ERR][NKM_SESSION] Device not auth")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN)
	return nkm_session


#Nakama socket
var nkm_socket: NakamaSocket setget _set_readonly_var, get_socket
var _nkm_socket_connecting: bool = false
signal socket_connected(nkm_socket)
signal received_friend_request_notification(notification)


func get_socket() -> NakamaSocket:
	if not nkm_socket:
		connect_nakama_socket()
	return nkm_socket


func connect_nakama_socket() -> void:
	if nkm_socket != null:
		return
	if _nkm_socket_connecting:
		return
	_nkm_socket_connecting = true

	var new_socket = Nakama.create_socket_from(nkm_client)
	var result: NakamaAsyncResult = yield(new_socket.connect_async(nkm_session), "completed")
	if not result.is_exception():
		nkm_socket = new_socket
		_nkm_socket_connecting = false

		nkm_socket.connect("connected", self, "_on_NakamaSocket_connected")
		nkm_socket.connect("closed", self, "_on_NakamaSocket_closed")
		nkm_socket.connect("received_notification", self, "_on_notification")

		emit_signal("socket_connected", nkm_socket)


func is_nakama_socket_connected() -> bool:
	return nkm_socket != null && nkm_socket.is_connected_to_host()


# Called when the socket was closed.
func _on_NakamaSocket_closed() -> void:
	# NotificationManager.show_custom_notification("Error", "Socket disconnected!")
	# ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
	nkm_socket = null


signal notif_wallet_updated(content)

# Handle notification by code
func _on_notification(notification: NakamaAPI.ApiNotification):
	match notification.code:
		NotificationCode.FRIEND_REQUEST_RECEIVED:
			emit_signal("received_friend_request_notification", notification)
		NotificationCode.WALLET_UPDATED:
			emit_signal("notif_wallet_updated", notification.content)


# Called when the socket was connected.
func _on_NakamaSocket_connected() -> void:
	return


# login
signal nakama_logged_in
signal nakama_login_err(err)
signal dev_auth_finished(result)
signal dev_auth
signal dev_unauth
signal not_connected


func login_async(email: String, pwd: String) -> void:
	self.nkm_session = yield(
		self.nkm_client.authenticate_email_async(email, pwd, null, false), "completed"
	)

	if nkm_session.is_exception():
		print("LOGIN_ERR: " + nkm_session.get_exception().message)
		emit_signal("nakama_login_err", nkm_session.get_exception().message)
		nkm_session = null
	else:
		device_link()
		print("LOGIN_LOG: Logged In!")
		emit_signal("nakama_logged_in")


func logout_async() -> void:
	device_unlink()
	yield(Conn.nkm_client.session_logout_async(Conn.nkm_session), "completed")


func device_auth(renew: bool = false) -> void:
	self.nkm_session = yield(
		self.nkm_client.authenticate_device_async(OS.get_unique_id() + "_duckdash", null, false),
		"completed"
	)
	if nkm_session.is_exception():
		print("AUTH_ERR: " + nkm_session.get_exception().message)
		if nkm_session.get_exception().message == "User account not found.":
			emit_signal("dev_auth_finished", false)
			emit_signal("dev_unauth")
		else:
			emit_signal("not_connected", nkm_session.get_exception().message)
		nkm_session = null
	else:
		print("LOGIN_LOG: Logged In using UID!")
		emit_signal("dev_auth_finished", true)
		if not renew:
			emit_signal("dev_auth")


# register
signal registered
signal register_err(err)


func register_async(email: String, usr: String, pwd: String) -> void:
	self.nkm_session = yield(
		self.nkm_client.authenticate_email_async(email, pwd, usr, true), "completed"
	)

	#check for error (a.k.a. exception) here
	if nkm_session.is_exception():
		var msg = nkm_session.get_exception().message
		if msg == "Invalid credentials.":
			#email is existed
			print("REG_ERR: Email exists.")
			pass
		elif msg == "":
			#unknown error
			print("REG_ERR: Unknown")
			pass
		else:
			print("REG_ERR: " + msg)
		Conn.nkm_session = null
		emit_signal("register_err", msg)

	else:
		device_link()
		Conn.nkm_session = nkm_session
		print("REG_LOG: Registered!")
		emit_signal("registered")


func device_link() -> bool:
	var device_id: String = OS.get_unique_id() + "_duckdash"
	var dev_id_linking: NakamaAsyncResult = yield(
		Conn.nkm_client.link_device_async(self.nkm_session, device_id), "completed"
	)

	if dev_id_linking.is_exception():
		print("LINK_DEV_ID_ERR: " + dev_id_linking.get_exception().message)
		return false
	else:
		print("LINK_DEV_ID_LOG: Linked!")
		return true


func device_unlink() -> bool:
	# var account: NakamaAPI.ApiAccount = yield(
	# 	nkm_client.get_account_async(nkm_session), "completed"
	# )

	# if account.is_exception():
	# 	push_error("Error getting account")
	# 	return false

	# for device in account.devices:
	# 	print("[LOG][UNLINK] " + str(device.id))
	# 	var dev_id_unlinking: NakamaAsyncResult = yield(
	# 		Conn.nkm_client.unlink_device_async(self.nkm_session, device.id), "completed"
	# 	)

	# 	if dev_id_unlinking.is_exception():
	# 		print("UNLINK_DEV_ID_ERR: " + dev_id_unlinking.get_exception().message)

	# 	else:
	# 		print("LINK_DEV_ID_LOG: Unlinked!")
	# print("[LOG][CONN] Un-Link")
	var device_id: String = OS.get_unique_id() + "_duckdash"
	var dev_id_unlinking: NakamaAsyncResult = yield(
		Conn.nkm_client.unlink_device_async(self.nkm_session, device_id), "completed"
	)

	if dev_id_unlinking.is_exception():
		print("LINK_DEV_ID_ERR: " + dev_id_unlinking.get_exception().message)
		return false
	else:
		print("LINK_DEV_ID_LOG: Unlinked!")
		return true

#equipment related
