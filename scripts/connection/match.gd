class_name DDMatch
extends Node

var self_peer_id: int = 0
var self_session_id: String
var match_id: String

var _next_peer_id: int = 1

# var nkm_socket: NakamaSocket setget _set_readonly_var

var players := {}

var players_ready := {}

var player_in_game_count: int = 1
var in_game_node: Node

var match_started := false



func _set_readonly_var(_value) -> void:
	pass


func _init(socket: NakamaSocket, session_id: String, _match_id: String, peer_id: int):
	print("[LOG][MATCH]New match " + _match_id)
	socket.connect("closed", self, "stop_game", [InGame.REASON_LOST_CONN])
	self_session_id = session_id
	match_id = _match_id
	self_peer_id = peer_id


func _ready() -> void:
	name = "Match"
	MatchManager.connect("error", self, "_on_MatchManager_error")
	MatchManager.connect("disconnected", self, "_on_MatchManager_disconnected")
	MatchManager.connect("player_status_changed", self, "_on_MatchManager_player_status_changed")
	MatchManager.connect("player_left", self, "_on_MatchManager_player_left")
	MatchManager.connect("match_created", self, "_on_MatchManager_match_created")
	randomize()


func _get_custom_rpc_methods() -> Array:
	return [
		"player_ready",
		"start_game",
		"player_in_game",
	]


func set_self_player(_player) -> void:
	# self_player = _player
	players[self_session_id] = _player


func set_players(data: Array) -> void:
	for user in data:
		players[user.presence.session_id] = PlayerInfo.new().from_presence(user.presence, 0)
	var session_ids = players.keys()
	session_ids.sort()
	for session_id in session_ids:
		players[session_id].peer_id = _next_peer_id
		_next_peer_id += 1
	self_peer_id = players[self_session_id].peer_id


####
# Lobby callbacks
func _on_Lobby_ready_pressed() -> void:
	MatchManager.custom_rpc_sync(self, "player_ready", [MatchManager.get_my_session_id()])


####
# MatchManager callbacks
func _on_MatchManager_match_created(_match_id: String) -> void:
	MatchManager.match_state = MatchManager.MatchState.READY
	print("nakama match created: " + match_id)
	if MatchManager.match_state != MatchManager.MatchState.PLAYING:
		MatchManager.start_playing()
	start_game()


func _on_MatchManager_error(_message: String):
	#if message != '':
	#ui_layer.show_message(message)
	#ui_layer.show_screen("MatchScreen")
	pass


func _on_MatchManager_disconnected():
	#_on_OnlineMatch_error("Disconnected from host")
	_on_MatchManager_error("")


func _on_MatchManager_player_left(player) -> void:
	#ui_layer.show_message(player.username + " has left")

	#game.kill_player(player.peer_id)

	players.erase(player.peer_id)
	players_ready.erase(player.peer_id)


func _on_MatchManager_player_status_changed(player, status) -> void:
	if status == MatchManager.PlayerStatus.CONNECTED:
		if MatchManager.is_network_server():
			# Tell this new player about all the other players that are already ready.
			for session_id in players_ready:
				MatchManager.custom_rpc_id(self, player.peer_id, "player_ready", [session_id])


####
# Gameplay methods and callbacks
func player_ready(session_id: String) -> void:
	#ready_screen.set_status(session_id, "READY!")

	if MatchManager.is_network_server() and not players_ready.has(session_id):
		print("[LOG][MATCH]Server instance")
		players_ready[session_id] = true
		if players_ready.size() == players.size():
			if MatchManager.match_state != MatchManager.MatchState.PLAYING:
				MatchManager.start_playing()
			MatchManager.custom_rpc_sync(self, "start_game", [])


func start_game() -> void:
	players = MatchManager.get_player_names_by_peer_id()
	in_game_node = ScreenManager.change_screen(ScreenManager.SCREEN_INGAME)
	if not MatchManager.is_network_server():
		MatchManager.custom_rpc(self, "player_in_game", [self_peer_id])
	elif MatchManager.match_mode == MatchManager.MatchMode.SINGLE:
		in_game_node.setup(players)


func player_in_game(_peer_id: int) -> void:
	if MatchManager.is_network_server():
		player_in_game_count += 1
		print("IN_GAME_PLAYER: " + str(player_in_game_count))
		print("PLAYER_COUNT: " + str(players.size()))
		if player_in_game_count == players.size():
			MatchManager.custom_rpc_sync(in_game_node, "setup", [players])


func stop_game(reason: String) -> void:
	MatchManager.emit_signal("game_over", reason)
	MatchManager.leave_current_match()

# func _on_Game_game_started() -> void:
# 	#ui_layer.hide_screen()
# 	#ui_layer.hide_all()
# 	#ui_layer.show_back_button()

# 	if not match_started:
# 		match_started = true

# func _on_Game_player_dead(player_id: int) -> void:
# 	var my_id = MatchManager.get_network_unique_id()
# 	if player_id == my_id:
# 		#ui_layer.show_message("You lose!")
# 		pass

# func _on_Game_game_over(player_id: int) -> void:
# 	players_ready.clear()
# 	if MatchManager.is_network_server():
# 		var player_session_id = MatchManager.get_session_id(player_id)
