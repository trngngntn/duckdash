extends Node

const CLIENT_VERSION = "dev"

var current_match: DDMatch setget set_current_match

var ruby_chance = 30
var emerald_chance = ruby_chance + 30
var amber_chance = emerald_chance + 30

#Nakama
var nkm_socket: NakamaSocket setget _set_readonly_var

var ticket: String

var min_player: int = 2
var max_player: int = 4

var cached_data

enum MatchState {
	LOBBY = 0,
	MATCHING = 1,
	CONNECTING = 2,
	WAITING_FOR_ENOUGH_PLAYERS = 3,
	READY = 4,
	PLAYING = 5,
}

var match_state: int = MatchState.LOBBY

enum MatchMode {
	NONE = 0,
	SINGLE = 1,
	MATCHMAKER = 2,
}
var match_mode: int = MatchMode.NONE

enum PlayerStatus {
	CONNECTING = 0,
	CONNECTED = 1,
}

signal error(message)
signal disconnected

signal match_created(match_id)
signal match_joined(match_id)
signal matchmaker_matched(players)

signal player_joined(player)
signal player_left(player)
signal player_status_changed(player, status)
signal host_disconnected

signal match_ready(players)
signal match_not_ready

signal game_over(reason)


func _set_readonly_var(_value) -> void:
	pass


func set_current_match(_match) -> void:
	if current_match:
		current_match.queue_free()
	current_match = _match
	if current_match:
		add_child(current_match)


static func serialize_players(_players: Dictionary) -> Dictionary:
	var result := {}
	for key in _players:
		result[key] = _players[key].to_dict()
	return result


static func unserialize_players(_players: Dictionary) -> Dictionary:
	var result := {}
	for key in _players:
		result[key] = PlayerInfo.new().from_dict(_players[key])
	return result


func _set_nakama_socket(_nkm_socket: NakamaSocket) -> void:
	if nkm_socket == _nkm_socket:
		return
	if nkm_socket:
		nkm_socket.disconnect("closed", self, "_on_nakama_closed")
		nkm_socket.disconnect("received_error", self, "_on_nakama_error")
		nkm_socket.disconnect("received_match_state", self, "_on_match_state_received")
		nkm_socket.disconnect("received_match_presence", self, "_on_nakama_match_presence")
		nkm_socket.disconnect("received_matchmaker_matched", self, "_on_matchmaker_matched")

	nkm_socket = _nkm_socket
	if nkm_socket:
		nkm_socket.connect("closed", self, "_on_nakama_closed")
		nkm_socket.connect("received_error", self, "_on_nakama_error")
		nkm_socket.connect("received_match_state", self, "_on_match_state_received")
		nkm_socket.connect("received_match_presence", self, "_on_nakama_match_presence")
		nkm_socket.connect("received_matchmaker_matched", self, "_on_matchmaker_matched")


func start_playing() -> void:
	assert(match_state == MatchState.READY)
	match_state = MatchState.PLAYING


func leave_current_match(close_socket: bool = false) -> void:
	#disconnect socket
	if nkm_socket:
		if current_match:
			print("[LOG][MATCH_MAN]Leave match " + current_match.match_id)
			yield(nkm_socket.leave_match_async(current_match.match_id), "completed")
		elif ticket:
			print("[LOG][MATCH_MAN]Remove matchmaker")
			yield(nkm_socket.remove_matchmaker_async(ticket), "completed")

		if close_socket:
			nkm_socket.close()
			_set_nakama_socket(null)

	# Initialize all the variables to their default state.
	ticket = ""
	self.current_match = null
	match_state = MatchState.LOBBY
	match_mode = MatchMode.NONE


####-----------------------------------------------------------------------------------------------
# match related function
func _check_enough_players() -> void:
	if current_match.players.size() >= min_player:
		match_state = MatchState.READY
		emit_signal("match_ready", current_match.players)
	else:
		match_state = MatchState.WAITING_FOR_ENOUGH_PLAYERS


func create_match(_nkm_socket: NakamaSocket) -> void:
	leave_current_match()
	# self.current_match = DDMatch.new("",)
	_set_nakama_socket(_nkm_socket)
	match_mode = MatchMode.SINGLE
	print("[LOG][MATCH_MAN]Creating match async started")
	var result = yield(nkm_socket.create_match_async(), "completed")
	print("[LOG][MATCH_MAN]Creating match async finished")
	if result.is_exception():
		leave_current_match()
		push_error("Failed to create singleplayer match, " + str(result.get_exception().message))
	else:
		_on_match_created(result)


func join_match(_nkm_socket: NakamaSocket, _match_id: String) -> void:
	pass


func start_matchmaking(_nkm_socket: NakamaSocket, data: Dictionary = {}) -> void:
	cached_data = data
	leave_current_match()
	_set_nakama_socket(_nkm_socket)
	match_mode = MatchMode.MATCHMAKER

	# if data.has('min_count'):
	# 	data['min_count'] = max(min_player, data['min_count'])
	# else:
	# 	data['min_count'] = min_player

	# if data.has('max_count'):
	# 	data['max_count'] = min(max_player, data['max_count'])
	# else:
	# 	data['max_count'] = max_player

	match_state = MatchState.MATCHING
	var result = yield(
		nkm_socket.add_matchmaker_async(
			data.get("query", "*"),
			data["min_count"],
			data["max_count"],
			data.get("string_properties", {}),
			data.get("numeric_properties", {})
		),
		"completed"
	)
	if result.is_exception():
		leave_current_match()
		emit_signal("error", "Unable to join match making pool")
		push_error("Join matchmaking error")
	else:
		print("MATCH_TICKET: " + str(result.ticket))
		ticket = result.ticket


####-----------------------------------------------------------------------------------------------
# NakamaConn callbacks
func _on_match_created(data: NakamaRTAPI.Match) -> void:
	self.current_match = DDMatch.new(nkm_socket, data.self_user.session_id, data.match_id, 1)
	var self_player = PlayerInfo.new().from_presence(data.self_user, 1)
	current_match.set_self_player(self_player)
	print("[LOG][MATCH_MAN]Match created")
	emit_signal("match_created", current_match.match_id)
	emit_signal("player_joined", self_player)
	emit_signal("player_status_changed", self_player, PlayerStatus.CONNECTED)


func _on_match_joined(data: NakamaRTAPI.Match) -> void:
	# if match_mode == MatchMode.JOIN:
	# current_match = DDMatch.new(data.self_user.session_id, data.match_id, -1)
	# 	emit_signal("match_joined", match_id)
	if match_mode == MatchMode.MATCHMAKER:
		current_match.match_id = data.match_id
		_check_enough_players()
	pass


func _on_matchmaker_matched(data: NakamaRTAPI.MatchmakerMatched) -> void:
	if data.is_exception():
		leave_current_match()
		emit_signal("error", "Matchmaking error")
		push_error("Matchmaker error")
		return

	self.current_match = DDMatch.new(nkm_socket, data.self_user.presence.session_id, "", -1)
	current_match.set_players(data.users)

	emit_signal("matchmaker_matched", current_match.players)

	for session_id in current_match.players:
		emit_signal(
			"player_status_changed", current_match.players[session_id], PlayerStatus.CONNECTED
		)

	#join match
	var result = yield(nkm_socket.join_matched_async(data), "completed")
	if result.is_exception():
		leave_current_match()
		emit_signal("error", "Unable to join matched match")
		push_error("Join error")
	else:
		_on_match_joined(result)
		pass


func _on_nakama_match_presence(data: NakamaRTAPI.MatchPresenceEvent) -> void:
	print("[LOG][MATCH_MAN]Presence received: " + str(data))
	if MatchMode.SINGLE:
		return
	for user in data.joins:
		if user.session_id == current_match.self_session_id:
			continue

		if match_mode == MatchMode.SINGLE:
			nkm_socket.send_match_state_async(
				current_match.match_id,
				MatchOpCode.JOIN_ERROR,
				JSON.print(
					{
						target = user["session_id"],
						reason = "Sorry! The match is full.,",
					}
				)
			)
		elif match_mode == MatchMode.MATCHMAKER:
			emit_signal("player_joined", current_match.players[user.session_id])

	if data.leaves.size() > 0:
		if match_state == MatchState.PLAYING:
			current_match.stop_game(InGame.REASON_PLAYER_LOST_CONN)
			return

		for user in data.leaves:
			if user.session_id == current_match.self_session_id:
				continue
			if not current_match.players.has(user.session_id):
				continue

			var player = current_match.players[user.session_id]

			# If the host disconnects, this is the end!
			emit_signal("player_left", player)
			print("[LOG][MATCH_MAN]Emitting player left signal")
			if player.peer_id == 1:
				leave_current_match()
				if match_state != MatchState.PLAYING:
					match_state = MatchState.LOBBY
					start_matchmaking(nkm_socket, cached_data)
				emit_signal("host_disconnected")

			else:
				current_match.players.erase(user.session_id)

				if current_match.players.size() < min_player:
					# If state was previously ready, but this brings us below the minimum players,
					# then we aren't ready anymore.
					if match_state == MatchState.READY || match_state == MatchState.PLAYING:
						emit_signal("match_not_ready")


func _on_match_state_received(data: NakamaRTAPI.MatchData) -> void:
	var result = JSON.parse(data.data)
	if result.error != OK:
		push_error("[ERR][MATCH_MAN]Error parsing JSON data")
		return
	var rpc_data = result.result

	if data.op_code == MatchOpCode.CUSTOM_RPC:
		if not rpc_data.has("peer_id") || rpc_data["peer_id"] == current_match.self_peer_id:
			var node = get_node(rpc_data["node_path"])
			if not node || not is_instance_valid(node) || node.is_queued_for_deletion():
				push_warning("CUSTOM_RPC_ERR: node is not valid")
				return
			if (
				not node.has_method("_get_custom_rpc_methods")
				|| not node._get_custom_rpc_methods().has(rpc_data["method"])
			):
				push_warning(
					(
						"CUSTOM_RPC_ERR: rpc method '"
						+ rpc_data["method"]
						+ "'' is not valid on path "
						+ rpc_data["node_path"]
					)
				)
				return
			node.callv(rpc_data["method"], str2var(rpc_data["args"]))

	if data.op_code == MatchOpCode.JOIN_SUCCESS && match_mode == MatchMode.JOIN:
		var host_client_version = rpc_data.get("client_version", "")
		if CLIENT_VERSION != host_client_version:
			leave_current_match()
			emit_signal("error", "Client version doesn't match host")
			return

		var content_players = unserialize_players(rpc_data["players"])

		current_match.self_peer_id = content_players[current_match.self_session_id].peer_id
		for session_id in content_players:
			if not current_match.players.has(session_id):
				current_match.players[session_id] = content_players[session_id]
				emit_signal("player_joined", current_match.players[session_id])
				emit_signal(
					"player_status_changed",
					current_match.players[session_id],
					PlayerStatus.CONNECTED
				)
		_check_enough_players()

	if data.op_code == MatchOpCode.JOIN_ERROR:
		if rpc_data["target"] == current_match.self_session_id:
			leave_current_match()
			emit_signal("error", rpc_data["reason"])


func get_network_unique_id() -> int:
	if current_match:
		return current_match.self_peer_id
	return -1


func is_network_server() -> bool:
	if current_match:
		return current_match.self_peer_id == 1
	return false


func get_player_names_by_peer_id() -> Dictionary:
	var result = {}
	for session_id in current_match.players:
		result[current_match.players[session_id]["peer_id"]] = current_match.players[session_id]["username"]
	return result


func is_network_master_for_node(node: Node) -> bool:
	if is_instance_valid(node) && not node.is_queued_for_deletion():
		return node.get_network_master() == current_match.self_peer_id
	return false


####-----------------------------------------------------------------------------------------------
# custom RPC functions
enum MatchOpCode {
	CUSTOM_RPC = 100,
	JOIN_SUCCESS = 101,
	JOIN_ERROR = 102,
}


func custom_rpc(node: Node, method: String, args: Array = []) -> void:
	if MatchManager.nkm_socket && current_match.players.size() > 1:
		nkm_socket.send_match_state_async(
			current_match.match_id,
			MatchOpCode.CUSTOM_RPC,
			JSON.print({node_path = str(node.get_path()), method = method, args = var2str(args)})
		)


func custom_rpc_id(node: Node, id: int, method: String, args: Array = []) -> void:
	if nkm_socket && current_match.players.size() > 1:
		nkm_socket.send_match_state_async(
			current_match.match_id,
			MatchOpCode.CUSTOM_RPC,
			JSON.print(
				{
					peer_id = id,
					node_path = str(node.get_path()),
					method = method,
					args = var2str(args)
				}
			)
		)


func custom_rpc_sync(node: Node, method: String, args: Array = []) -> void:
	node.callv(method, args)
	custom_rpc(node, method, args)


func custom_rpc_id_sync(node: Node, id: int, method: String, args: Array = []) -> void:
	if id == current_match.self_peer_id:
		node.callv(method, args)
	else:
		custom_rpc_id(node, id, method, args)
