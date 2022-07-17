extends Control

const PARTY_SIZE = 4

var players := {}
var players_ready := {}

var party_size = 1
var players_slot = {}

signal ready_pressed

var gamemode
var is_match = false


func _ready():
	var _result := $Control/ButtonContainer/PlayButton.connect("pressed", self, "_on_match_button_pressed", [NakamaMatch.MatchMode.SINGLE])
	_result = $Control/ButtonContainer/MatchmakingButton.connect("pressed", self, "_on_match_button_pressed", [NakamaMatch.MatchMode.MATCHMAKER])

	_result = NakamaMatch.connect("match_created", self, "_on_NakamaMatch_match_created")
	_result = NakamaMatch.connect("matchmaker_matched", self, "_on_NakamaMatch_matchmaker_matched")
	_result = NakamaMatch.connect("player_joined", self, "_on_NakamaMatch_player_joined")
	_result = NakamaMatch.connect("player_left", self, "_on_NakamaMatch_player_left")
	_result = NakamaMatch.connect(
		"player_status_changed", self, "_on_NakamaMatch_player_status_changed"
	)
	_result = NakamaMatch.connect("match_ready", self, "_on_NakamaMatch_match_ready")
	_result = NakamaMatch.connect("match_not_ready", self, "_on_NakamaMatch_match_not_ready")

	#Match
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		#ui_layer.show_screen("ConnectionScreen", { reconnect = true, next_screen = null })
		
		# Wait to see if we get a new valid session.
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			#TODO: show a try again dialog
			return
	
	# Connect socket to realtime Nakama API if not connected.
	if not Conn.is_nakama_socket_connected():
		Conn.connect_nakama_socket()
		yield(Conn, "socket_connected")

	for i in range(1, PARTY_SIZE + 1):
		players_slot[i] = get_node("Control/PlayerListCont/PlayerSlot" + str(i))

	players_slot[1].set_player_name(Conn.nkm_session.username)


func set_status(id, st) -> void:
	pass


func add_player(session_id: String, username: String) -> void:
	pass


func del_player(session_id: String) -> void:
	pass


func reset_buttons() -> void:
	$Control/ButtonContainer/MatchmakingButton.visible = false
	$Control/ButtonContainer/ReadyButton.visible = false
	$Control/ButtonContainer/PlayButton.visible = false


func update_party_size(size: int) -> void:
	if size >= 1 && size <= 4:
		party_size = size
		$Control/MarginContainer/PartySizeControl/Status.text = "Party size: " + str(size)
		for i in range(1, PARTY_SIZE + 1):
			if i <= size:
				players_slot[i].visible = true
			else:
				players_slot[i].visible = false
		reset_buttons()
		if size == 1:
			$Control/ButtonContainer/PlayButton.visible = true
		else:
			$Control/ButtonContainer/MatchmakingButton.visible = true

func _create_match() -> void:
	NakamaMatch.create_match(Conn.nkm_socket)

func _start_matchmaking() -> void:
	var data = {
		min_count = party_size,
		max_count = party_size,
		string_properties = {game = "duckdash", version = "dev"},
		query = "+properties.game:duckdash",
	}
	print("looking for matches")
	NakamaMatch.start_matchmaking(Conn.nkm_socket, data)


####-----------------------------------------------------------------------------------------------
# local callbacks


func _on_AddButton_pressed() -> void:
	update_party_size(party_size + 1)


func _on_SubButton_pressed() -> void:
	update_party_size(party_size - 1)

func _on_match_button_pressed(mode) -> void:
	match mode:
		NakamaMatch.MatchMode.MATCHMAKER:
			_start_matchmaking()
			#show loading dots
			for i in range(2, PARTY_SIZE + 1):
				if players_slot[i].visible:
					players_slot[i].loading()
		NakamaMatch.MatchMode.SINGLE:
			_create_match()

func _on_ReadyButton_pressed() -> void:
	emit_signal("ready_pressed")


####-----------------------------------------------------------------------------------------------
# NakamaMatch callbacks
func _on_NakamaMatch_matchmaker_matched(players: Dictionary) -> void:
	var self_user_f : bool = false
	players_slot[1].set_status("CONNECTED")
	for player_session_id in players:
		if player_session_id == NakamaMatch.self_session_id:
			self_user_f = true
			continue
		var player: NakamaMatch.Player= players[player_session_id]
		var pos := player.peer_id
		if not self_user_f:
			pos += 1
		players_slot[pos].set_player_name(player.username)
		players_slot[pos].set_status("CONNECTED")
	pass

func _on_NakamaMatch_match_created(match_id: String) -> void:
	print("Match created: " + match_id)
	pass


func _on_NakamaMatch_player_joined(player) -> void:
	#add_player(player.session_id, player.usernam)
	pass


func _on_NakamaMatch_player_left(player) -> void:
	#del_player(player.session_id, player.username)
	pass


func _on_NakamaMatch_player_status_changed(player, status) -> void:
	# if status == NakamaMatch.PlayerStatus.CONNECTED:
	# 	if get_status(player.session_id) != "READY":
	# 		set_status(player.session_id, "Connected")
	# elif status == NakamaMatch.PlayerStatus.CONNECTING:
	# 	set_status(player.session_id, "Connecting...")
	pass
