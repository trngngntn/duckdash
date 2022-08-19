extends Control

const TITLE = "LOBBY"
const PARTY_SIZE = 4

var player_slot = preload("res://scenes/ui/player_slot.tscn")

var players := {}
var players_ready := {}

var party_size = 1

signal ready_pressed

var gamemode
var is_match = false


func _ready():
	$ButtonContainer/PlayButton.connect(
		"pressed", self, "_on_match_button_pressed", [MatchManager.MatchMode.SINGLE]
	)
	# $ButtonContainer/MatchmakingButton.connect(
	# 	"pressed", self, "_on_match_button_pressed", [MatchManager.MatchMode.MATCHMAKER]
	# )

	MatchManager.connect("match_created", self, "_on_MatchManager_match_created")
	MatchManager.connect("matchmaker_matched", self, "_on_MatchManager_matchmaker_matched")
	MatchManager.connect("player_joined", self, "_on_MatchManager_player_joined")
	MatchManager.connect("player_left", self, "_on_MatchManager_player_left")
	MatchManager.connect("player_status_changed", self, "_on_MatchManager_player_status_changed")
	MatchManager.connect("match_ready", self, "_on_MatchManager_match_ready")
	MatchManager.connect("match_not_ready", self, "_on_MatchManager_match_not_ready")
	ScreenManager.connect("go_back", self, "on_go_back")

	#Match
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.device_auth()
		#ui_layer.show_screen("ConnectionScreen", { reconnect = true, next_screen = null })

		# Wait to see if we get a new valid session.
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			#TODO: show a try again dialog
			ScreenManager.change_screen(ScreenManager.SCREEN_MENU)
			return

	# Connect socket to realtime Nakama API if not connected.
	if not Conn.is_nakama_socket_connected():
		Conn.connect_nakama_socket()
		yield(Conn, "socket_connected")

	add_player_slot(Conn.nkm_session.username)


func on_go_back():
	print("[LOG][LOBBY]Leave")
	MatchManager.leave_current_match()
	queue_free()


func set_status(id, st) -> void:
	pass


func add_player_slot(usr: String) -> void:
	print("[LOG][LOBBY]Add slot " + usr)
	var slot = player_slot.instance()
	slot.name = usr
	print("SLOOT")
	$PlayerListCont.add_child(slot)


func add_player(_player: PlayerInfo) -> void:
	if not players.has(_player.session_id):
		players[_player.session_id] = _player

	if not $PlayerListCont.get_node(_player.username):
		add_player_slot(_player.username)


func del_player(_player: PlayerInfo) -> void:
	players.erase(_player.session_id)
	$PlayerListCont.get_node(_player.username).queue_free()


func reset_buttons() -> void:
	$ButtonContainer/MatchmakingButton.visible = false
	$ButtonContainer/ReadyButton.visible = false
	$ButtonContainer/PlayButton.visible = false


func update_party_size(size: int) -> void:
	if size >= 1 && size <= 4:
		party_size = size
		$PartyControl/PartySizeControl/Status.text = "Party size: " + str(size)
		reset_buttons()
		if size == 1:
			$ButtonContainer/PlayButton.visible = true
		else:
			$ButtonContainer/MatchmakingButton.visible = true


func _create_match() -> void:
	MatchManager.create_match(Conn.nkm_socket)


func _start_matchmaking() -> void:
	var data = {
		min_count = party_size,
		max_count = party_size,
		string_properties = {game = "duckdash", version = "dev"},
		query = "+properties.game:duckdash",
	}
	MatchManager.start_matchmaking(Conn.nkm_socket, data)


func player_ready(player_session_id: String) -> void:
	$PlayerListCont.get_node(players[player_session_id].username).set_status("READY")


####-----------------------------------------------------------------------------------------------
# local callbacks
func _on_AddButton_pressed() -> void:
	update_party_size(party_size + 1)


func _on_SubButton_pressed() -> void:
	update_party_size(party_size - 1)


func _on_match_button_pressed(mode) -> void:
	match mode:
		MatchManager.MatchMode.MATCHMAKER:
			_start_matchmaking()
		MatchManager.MatchMode.SINGLE:
			if EquipmentManager.equipped["skill_caster"].size() == 0:
				$ButtonContainer/ReadyButton.pressed = false
				ScreenManager.show_notification("Equipment", "Please select a weapon")
			else:
				_create_match()


func _on_ReadyButton_toggled(button_pressed: bool):
	if button_pressed:
		if EquipmentManager.equipped["skill_caster"].size() == 0:
			$ButtonContainer/ReadyButton.pressed = false
			ScreenManager.show_notification("Equipment", "Please select a weapon")
		else:
			MatchManager.custom_rpc_sync(
				MatchManager.current_match,
				"player_ready",
				[MatchManager.current_match.self_session_id]
			)


func _on_MatchmakingButton_toggled(button_pressed: bool):
	if button_pressed:
		_start_matchmaking()
		$ButtonContainer/MatchmakingButton.text = ""
		$ButtonContainer/MatchmakingButton/LoadingDots.show()
		$PartyControl/PartySizeControl/AddButton.disabled = true
		$PartyControl/PartySizeControl/SubButton.disabled = true
	else:
		MatchManager.leave_current_match()
		$ButtonContainer/MatchmakingButton/LoadingDots.hide()
		$ButtonContainer/MatchmakingButton.text = "Find Game"
		$PartyControl/PartySizeControl/AddButton.disabled = false
		$PartyControl/PartySizeControl/SubButton.disabled = false


####-----------------------------------------------------------------------------------------------
# MatchManager callbacks
func _on_MatchManager_matchmaker_matched(_players: Dictionary) -> void:
	$PartyControl.hide()
	players = _players
	for player_session_id in players:
		var player: PlayerInfo = players[player_session_id]
		if player_session_id != MatchManager.current_match.self_session_id:
			add_player(player)
		if $PlayerListCont.get_node(player.username):
			$PlayerListCont.get_node(player.username).set_status("CONNECTED")


func _on_MatchManager_match_created(match_id: String) -> void:
	print("[LOG][LOBBY]Match created: " + match_id)
	pass


func _on_MatchManager_match_ready(_players) -> void:
	$ButtonContainer/MatchmakingButton.visible = false
	$ButtonContainer/ReadyButton.visible = true


func _on_MatchManager_player_joined(_player) -> void:
	add_player(_player)


func _on_MatchManager_player_left(_player) -> void:
	del_player(_player)


func _on_MatchManager_player_status_changed(_player, status) -> void:
	print("[LOG][MATCH]Received status change")
	# if status == MatchManager.PlayerStatus.CONNECTED:
	# 	if get_status(player.session_id) != "READY":
	# 		set_status(player.session_id, "Connected")
	# elif status == MatchManager.PlayerStatus.CONNECTING:
	# 	set_status(player.session_id, "Connecting...")
	pass
