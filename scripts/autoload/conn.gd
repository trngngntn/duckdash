extends Node

onready var self_instance = self

var nkm_server_key: String = "duckdash_nakama"
var nkm_host: String = "10.144.0.2"
var nkm_port: int = 7350
var nkm_scheme: String = "http"

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
	
	if nkm_session and not nkm_session.is_exception() and not nkm_session.is_expired():
		print("session_connected")
		emit_signal("session_connected", nkm_session)


#Nakama socket
var nkm_socket: NakamaSocket setget _set_readonly_var
var _nkm_socket_connecting: bool = false
signal socket_connected(nkm_socket)


func connect_nakama_socket() -> void:
	if nkm_socket != null:
		return
	if _nkm_socket_connecting:
		return
	_nkm_socket_connecting = true

	var new_socket = Nakama.create_socket_from(nkm_client)
	yield(new_socket.connect_async(nkm_session), "completed")
	nkm_socket = new_socket
	_nkm_socket_connecting = false

	emit_signal("socket_connected", nkm_socket)


func is_nakama_socket_connected() -> bool:
	return nkm_socket != null && nkm_socket.is_connected_to_host()


# login
signal nakama_logged_in()
signal nakama_login_err(err)
signal dev_auth()
signal dev_unauth()

func login_async(email: String, pwd: String) -> void:
	self.nkm_session = yield(
		self.nkm_client.authenticate_email_async(email, pwd, null, false), "completed"
	)

	if nkm_session.is_exception():
		print("LOGIN_ERR: " + nkm_session.get_exception().message)
		emit_signal("nakama_login_err", nkm_session.get_exception().message)
		nkm_session = null
	else:
		print("LOGIN_LOG: Logged In!")
		emit_signal("nakama_logged_in")


func device_auth() -> void:
	self.nkm_session = yield(
		self.nkm_client.authenticate_device_async(OS.get_unique_id() + "_duckdash", null, false), "completed"
	)
	if nkm_session.is_exception():
		print("LOGIN_ERR: " + nkm_session.get_exception().message)
		emit_signal("dev_unauth")
		nkm_session = null
	else:
		print("LOGIN_LOG: Logged In using UID!")
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
		var device_id: String = OS.get_unique_id() + "_duckdash"
		var dev_id_linking: NakamaAsyncResult = yield(
			Conn.nkm_client.link_device_async(nkm_session, device_id), "completed"
		)

		if dev_id_linking.is_exception():
			print("LINK_DEV_ID_ERR: " + dev_id_linking.get_exception().message)
		else:
			print("LINK_DEV_ID_LOG: Linked!")

		Conn.nkm_session = nkm_session
		print("REG_LOG: Registered!")
		emit_signal("registered")

#equipment related
