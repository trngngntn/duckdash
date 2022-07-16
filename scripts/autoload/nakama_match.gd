extends Node

const CLIENT_VERSION = "dev"

#Nakama
var nkm_socket: NakamaSocket setget _set_readonly_var
var self_session_id: String
var match_id: String
var ticket: String

#RPC
var self_peer_id: int

var players: Dictionary
var _next_peer_id: int

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

signal match_ready(players)
signal match_not_ready


class Player:
	var session_id: String
	var peer_id: int
	var username: String

	func _init(_session_id: String, _username: String, _peer_id: int) -> void:
		session_id = _session_id
		username = _username
		peer_id = _peer_id

	static func from_presence(presence: NakamaRTAPI.UserPresence, _peer_id: int) -> Player:
		return Player.new(presence.session_id, presence.username, _peer_id)

	static func from_dict(data: Dictionary) -> Player:
		return Player.new(data["session_id"], data["username"], int(data["peer_id"]))

	func to_dict() -> Dictionary:
		return {
			session_id = session_id,
			username = username,
			peer_id = peer_id,
		}


func _set_readonly_var(_value) -> void:
	pass


func _set_nakama_socket(_nkm_socket: NakamaSocket) -> void:
	if nkm_socket == _nkm_socket:
		return
	#disconnect old socket signals
	if nkm_socket:
		nkm_socket.disconnect("closed", self, "_on_nakama_closed")
		nkm_socket.disconnect("received_error", self, "_on_nakama_error")
		nkm_socket.disconnect("received_match_state", self, "_on_nakama_match_state")
		nkm_socket.disconnect("received_match_presence", self, "_on_nakama_match_presence")
		nkm_socket.disconnect("received_matchmaker_matched", self, "_on_nakama_matchmaker_matched")

	nkm_socket = _nkm_socket

	#connect new socket signals
	if nkm_socket:
		nkm_socket.connect("closed", self, "_on_nakama_closed")
		nkm_socket.connect("received_error", self, "_on_nakama_error")
		nkm_socket.connect("received_match_state", self, "_on_nakama_match_state")
		nkm_socket.connect("received_match_presence", self, "_on_nakama_match_presence")
		nkm_socket.connect("received_matchmaker_matched", self, "_on_nakama_matchmaker_matched")


func start_playing() -> void:
	assert(match_state == MatchState.READY)
	match_state = MatchState.PLAYING


func leave(close_socket: bool = false) -> void:
	#Disconnect Nakama
	if nkm_socket:
		if match_id:
			yield(nkm_socket.leave_match_async(match_id), "completed")
		elif ticket:
			yield(nkm_socket.remove_matchmaker_async(ticket), "completed")

		if close_socket:
			nkm_socket.close()
			_set_nakama_socket(null)

	# Initialize all the variables to their default state.
	self_session_id = ""
	match_id = ""
	ticket = ""
	players = {}
	self_peer_id = 0
	_next_peer_id = 1
	match_state = MatchState.LOBBY
	match_mode = MatchMode.NONE


func create_match(_nkm_socket: NakamaSocket) -> void:
	leave()
	_set_nakama_socket(_nkm_socket)
	match_mode = MatchMode.SINGLE

	var result = yield(nkm_socket.create_match_async(), "completed")
	if result.is_exception():
		leave()
		print("MM_ERR: failed to create singleplayer match, " + str(result.get_exception().message))
	else:
		_on_match_created(result)


func join_match(_nkm_socket: NakamaSocket, _match_id: String) -> void:
	pass


func start_matchmaking(_nkm_socket: NakamaSocket, data: Dictionary = {}) -> void:
	leave()
	_set_nakama_socket(_nkm_socket)
	match_mode = MatchMode.MATCHMAKER

	# if data.has('min_count'):
	# 	data['min_count'] = max(min_players, data['min_count'])
	#   else:
	# 	data['min_count'] = min_players

	#   if data.has('max_count'):
	# 	data['max_count'] = min(max_players, data['max_count'])
	#   else:
	# 	data['max_count'] = max_players

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
		leave()
		emit_signal("error", "Unable to join match making pool")
	else:
		ticket = result.ticket


func _on_match_created(data: NakamaRTAPI.Match) -> void:
	match_id = data.match_id
	self_session_id = data.self_user.session_id
	var self_player = Player.from_presence(data.self_user, 1)
	players[self_session_id] = self_player
	self_peer_id = 1

	emit_signal("match_created", match_id)
	emit_signal("player_joined", self_player)
	emit_signal("player_status_changed", self_player, PlayerStatus.CONNECTED)


func _on_match_joined(data: NakamaRTAPI.Match) -> void:
	match_id = data.match_id
	self_session_id = data.self_user.session_id

	# if match_mode == MatchMode.JOIN:
	# 	emit_signal("match_joined", match_id)
	# elif match_mode == MatchMode.MATCHMAKER:
	# 	_check_enough_player()
	pass


func _on_matchmaker_matched(data: NakamaRTAPI.MatchmakerMatched) -> void:
	if data.is_exception():
		leave()
		emit_signal("error", "Matchmaking error")
		return

	self_session_id = data.self_user.presence.session_id

	for user in data.users:
		players[user.presence.session_id] = Player.from_presence(user.presence, 0)

	var session_ids = players.keys()
	session_ids.sort()
	for session_id in session_ids:
		players[session_id].peer_id = _next_peer_id
		_next_peer_id += 1

	self_peer_id = players[self_session_id].peer_id
	emit_signal("matchmaker_matched", players)

	for session_id in players:
		emit_signal("player_status_changed", players[session_id], PlayerStatus.CONNECTED)

	#join match
	var result = yield(nkm_socket.join_matched_async(data), "completed")
	if result.is_exception():
		leave()
		emit_signal("error", "Unable to join matched match")
	else:
		_on_match_joined(result)
		pass


enum MatchOpCode { CUSTOM_RPC = 100 }


func custom_rpc(node: Node, method: String, args: Array = []) -> void:
	if nkm_socket:
		nkm_socket.send_match_state_async(
			match_id,
			MatchOpCode.CUSTOM_RPC,
			JSON.print({node_path = str(node.get_path()), method = method, args = var2str(args)})
		)


func custom_rpc_id(node: Node, id: int, method: String, args: Array = []) -> void:
	if nkm_socket:
		nkm_socket.send_match_state_async(
			match_id,
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
	custom_rpc(node, method, args)
	node.callv(method, args)


func custom_rpc_id_sync(node: Node, id: int, method: String, args: Array = []) -> void:
	if id == self_peer_id:
		node.callv(method, args)
	else:
		custom_rpc_id(node, id, method, args)


func _on_match_state_received(data: NakamaRTAPI.MatchData) -> void:
	var result = JSON.parse(data.data)
	if result.error != OK:
		print("MATCH_JSON_ERR")
		return
	var rpc_data = result.result

	if data.op_code == MatchOpCode.CUSTOM_RPC:
		if not rpc_data.has("peer_id") || rpc_data["peer_id"] == self_peer_id:
			var node = get_node(rpc_data["node_path"])
			if not node || not is_instance_valid(node) || node.is_queued_for_deletion():
				push_warning("CUSTOM_RPC_ERR: node is not valid")
				return
			if (
				not node.has_method("_get_custom_rpc_methods")
				|| not node._get_custom_rpc_methods().has(rpc_data["method"])
			):
				push_warning("CUSTOM_RPC_ERR: rpc method is not valid")
				return
			node.callv(rpc_data["method"], str2var(rpc_data["args"]))


func get_network_unique_id() -> int:
	return self_peer_id

func get_player_names_by_peer_id() -> Dictionary:
	var result = {}
	for session_id in players:
		result[players[session_id]['peer_id']] = players[session_id]['username']
	return result

