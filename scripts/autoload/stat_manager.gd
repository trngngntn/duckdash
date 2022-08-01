extends Node

var atk_damamge: float = 5
var atk_range: float = 1
var atk_speed: float = 1
var fire_rate: float = 1
var crit_chance: float = 0
var crit_mul: float = 2
var proj_speed: float = 1
var proj_num: float = 1
var proj_pierce: float = 0

var stat_info_list: Dictionary = {}\

func _init():
	Conn.connect("session_connected", self, "_on_session_created")

# func _ready() -> void:
	
# 	yield(Conn.self_instance, "session_connected")
	

func _on_session_created(_d) -> void:
	fetch_stat_info()

func fetch_stat_info() -> void:
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "get_stat_info_list", null), "completed"
	)
	if response.is_exception():
		printerr("ERR_FETCH_STAT_INFO_LIST: %s" % response)
		return null
	else:
		print(response.payload)
		var result = JSON.parse(response.payload).result
		for raw_stat_info in result:
			stat_info_list[raw_stat_info["id"]] = {}
			stat_info_list[raw_stat_info["id"]]["format"] = raw_stat_info["format"]
		


# Fetch stat of character from Nakama Server
func fetch_player_stat() -> void:
	pass
