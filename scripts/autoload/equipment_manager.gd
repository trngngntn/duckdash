extends Node


func craft_equipment() -> void:
	var payload = {"hat": "cowboy"}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "roll_equipment", JSON.print(payload)),"completed"
	)
	if response.is_exception():
		print("An error occurred: %s" % response)
		return
	else :
		print(response._to_string())
