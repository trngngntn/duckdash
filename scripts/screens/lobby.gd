extends Control

const PARTY_SIZE = 4

var players := {}
var players_ready := {}

var party_size = 1
var players_slot = {}

signal ready_pressed


func _ready():
	var _result := NakamaMatch.connect("match_created", self, "_on_NakamaMatch_match_created")
	_result = NakamaMatch.connect("player_joined", self, "_on_NakamaMatch_player_joined")
	_result = NakamaMatch.connect("player_left", self, "_on_NakamaMatch_player_left")
	_result = NakamaMatch.connect(
		"player_status_changed", self, "_on_NakamaMatch_player_status_changed"
	)
	_result = NakamaMatch.connect("match_ready", self, "_on_NakamaMatch_match_ready")
	_result = NakamaMatch.connect("match_not_ready", self, "_on_NakamaMatch_match_not_ready")
	_result = Conn.connect("socket_connected", self, "_on_Conn_socket_connected")
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


####
# local callbacks


func _on_AddButton_pressed():
	update_party_size(party_size + 1)


func _on_SubButton_pressed():
	update_party_size(party_size - 1)


func _on_PlayButton_pressed():
	Conn.connect_nakama_socket()


func _on_ReadyButton_pressed() -> void:
	emit_signal("ready_pressed")


####
# NakamaConn callbacks


func _on_Conn_socket_connected(socket: NakamaSocket) -> void:
	NakamaMatch.create_match(Conn.nkm_socket)


####
# NakamaMatch callbacks


func _on_NakamaMatch_match_created(match_id: String) -> void:
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
