extends Node

var players := {}

var players_ready := {}

var match_started := false


func _ready() -> void:
	var _result := NakamaMatch.connect("error", self, "_on_NakamaMatch_error")
	_result = NakamaMatch.connect("disconnected", self, "_on_NakamaMatch_disconnected")
	_result = NakamaMatch.connect(
		"player_status_changed", self, "_on_NakamaMatch_player_status_changed"
	)
	_result = NakamaMatch.connect("player_left", self, "_on_NakamaMatch_player_left")
	_result = NakamaMatch.connect("match_created", self, "_on_NakamaMatch_match_created")
	print("OHHHH")
	randomize()


func _get_custom_rpc_methods() -> Array:
	return [
		"player_ready",
	]


####
# Lobby callbacks
func _on_Lobby_ready_pressed() -> void:
	NakamaMatch.custom_rpc_sync(self, "player_ready", [NakamaMatch.get_my_session_id()])


####
# NakamaMatch callbacks
func _on_NakamaMatch_match_created(match_id: String) -> void:
	NakamaMatch.match_state = NakamaMatch.MatchState.READY
	print("nakama match created: " + match_id)
	if NakamaMatch.match_state != NakamaMatch.MatchState.PLAYING:
		NakamaMatch.start_playing()
	start_game()


func _on_NakamaMatch_error(message: String):
	#if message != '':
	#ui_layer.show_message(message)
	#ui_layer.show_screen("MatchScreen")
	pass


func _on_NakamaMatch_disconnected():
	#_on_OnlineMatch_error("Disconnected from host")
	_on_NakamaMatch_error("")


func _on_NakamaMatch_player_left(player) -> void:
	#ui_layer.show_message(player.username + " has left")

	#game.kill_player(player.peer_id)

	players.erase(player.peer_id)
	players_ready.erase(player.peer_id)


func _on_OnlineMatch_player_status_changed(player, status) -> void:
	if status == NakamaMatch.PlayerStatus.CONNECTED:
		if NakamaMatch.is_network_server():
			# Tell this new player about all the other players that are already ready.
			for session_id in players_ready:
				NakamaMatch.custom_rpc_id(self, player.peer_id, "player_ready", [session_id])


####
# Gameplay methods and callbacks
func player_ready(session_id: String) -> void:
	#ready_screen.set_status(session_id, "READY!")

	if NakamaMatch.is_network_server() and not players_ready.has(session_id):
		players_ready[session_id] = true
		if players_ready.size() == NakamaMatch.players.size():
			if NakamaMatch.match_state != NakamaMatch.MatchState.PLAYING:
				NakamaMatch.start_playing()
			start_game()


func start_game() -> void:
	players = NakamaMatch.get_player_names_by_peer_id()
	var _scrn = ScreenManager.change_screen(ScreenManager.SCREEN_INGAME)


func stop_game() -> void:
	NakamaMatch.leave()
	players.clear()
	players_ready.clear()
	#game.game_stop()


func _on_Game_game_started() -> void:
	#ui_layer.hide_screen()
	#ui_layer.hide_all()
	#ui_layer.show_back_button()

	if not match_started:
		match_started = true


func _on_Game_player_dead(player_id: int) -> void:
	var my_id = NakamaMatch.get_network_unique_id()
	if player_id == my_id:
		#ui_layer.show_message("You lose!")
		pass


func _on_Game_game_over(player_id: int) -> void:
	players_ready.clear()
	if NakamaMatch.is_network_server():
		var player_session_id = NakamaMatch.get_session_id(player_id)
