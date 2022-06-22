extends Node

var nkm_server_key: String = 'duckdash_nakama'
var nkm_host: String = '10.144.0.2'
var nkm_port: int = 7350
var nkm_scheme: String = 'http'

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
			NakamaLogger.LOG_LEVEL.ERROR)

	return nkm_client

#Nakama session
var nkm_session: NakamaSession setget set_nakama_session
signal session_changed (nkm_session)
signal session_connected (nkm_session)

func set_nakama_session(_nkm_session: NakamaSession) -> void:
	nkm_session = _nkm_session
	emit_signal("session_changed", nkm_session)

#Nakama socket
var nkm_socket: NakamaSocket setget _set_readonly_var
var _nkm_socket_connecting: bool = false;
signal socket_connected (nkm_socket)

func connect_nakama_socket() -> void:
	if nkm_socket != null:
		return
	if _nkm_socket_connecting:
		return
	_nkm_socket_connecting = true;

	var new_socket = Nakama.create_socket_from(nkm_client)
	yield(new_socket.connect_async(nkm_session), "completed")
	nkm_socket = new_socket
	_nkm_socket_connecting = false
	
	emit_signal("socket_connected", nkm_socket)

func is_nakama_socket_connected() -> bool:
	return nkm_socket != null && nkm_socket.is_connected_to_host()

func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass
