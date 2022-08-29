class_name InGame extends Node2D

const REASON_EXIT = "You stopped trying!"
const REASON_PLAYER_EXIT = "A player in your party can't handle the heat!"
const REASON_YOU_DIED = "You died!"
const REASON_PLAYER_DIED = "A player in your party died!"
const REASON_LOST_CONN = "Lost connection!"
const REASON_PLAYER_LOST_CONN = "A player in your party lost connection!"

var Player = preload("res://scenes/character/duck.tscn")

var player_list: Node
var map

var game_started := false
var game_over := false
var players_alive := {}
var players_setup := {}

var my_player: Duck
var my_id: int

signal map_generated
signal game_started
signal player_dead(player_id)

onready var hp_bar := $CanvasLayer/HPBar
onready var mv_joystick = $CanvasLayer/MoveControl/MoveJoystick
onready var atk_joystick = $CanvasLayer/AttackControl/AttackJoystick


func _get_custom_rpc_methods() -> Array:
	return [
		"generate_map",
		"setup",
		"_finish_setup",
		"_start",
	]


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	mv_joystick.set_snap_step(1)
	MatchManager.connect("game_over", self, "_on_game_over")


func generate_map(map_seed: int) -> void:
	print("GEN_MAP: " + str(map_seed))
	var map_generator: MapGenerator = MapGenerator.new()
	var gen_stratergy = OpenSimplexNoiseStrategy.new()
	map_generator.set_strategy(gen_stratergy)
	map = map_generator.generate_map(map_seed)
	$Back.add_child(map)
	emit_signal("map_generated")


# Initializes the game so that it is ready to really start.
func setup(players: Dictionary) -> void:
	get_tree().paused = true

	if MatchManager.is_network_server():
		$CanvasLayer/TestLabel.text = "SERVER_INSTANCE"
		randomize()
		var map_seed: int = 100
		MatchManager.custom_rpc_sync(self, "generate_map", [map_seed])
	elif not map:
		yield(self, "map_generated")

	game_started = false
	game_over = false
	players_alive = players

	for player_id in players:
		var player = Player.instance()
		player.name = "Player" + str(player_id)

		map.player_cont.add_child(player)
		player.set_network_master(player_id)
		player.set_player_name(players[player_id])

		player.connect("dead", self, "_on_player_dead", [player_id])
		player.add_to_group("player")
		if player_id == MatchManager.get_network_unique_id():
			my_id = player_id
			my_player = player

	# setup for current player
	StatManager.calculate_stat()
	yield(StatManager, "stat_calculated")
	
	my_player.map_move_joystick(mv_joystick)
	my_player.map_attack_joystick(atk_joystick)

	my_player.tracking_cam = $GameCamera
	$GameCamera.set_node_tracking(my_player)
	$GameCamera.current = true

	MatchManager.custom_rpc_sync(self, "_finish_setup", [my_id, StatManager.current_stat.to_dict()])


# Records when each player has finished setup so we know when all players are ready.
func _finish_setup(peer_id: int, player_stat_dict: Dictionary) -> void:
	if MatchManager.current_match.self_peer_id != peer_id:
		var player_stat = StatManager.StatValues.new().from_dict(player_stat_dict)
		StatManager.players_stat[peer_id] = player_stat
	if MatchManager.is_network_server():
		players_setup[peer_id] = players_alive[peer_id]
		if players_setup.size() == players_alive.size():
			MatchManager.custom_rpc_sync(self, "_start")


func _start() -> void:
	if map.has_method("map_start"):
		map.map_start()
	for player in get_tree().get_nodes_in_group("player"):
		player.finish_setup()
	emit_signal("game_started")
	get_tree().paused = false
	Updater.start()
	$CanvasLayer/PlayerMarkerCont.setup(my_player, get_tree().get_nodes_in_group("player"))


func _on_game_over(reason: String) -> void:
	Updater.stop()
	game_over = true
	if not is_instance_valid(map) || map.is_queued_for_deletion():
		remove_child(map)
		map.queue_free()
	$CanvasLayer/GameOver.set_reason(reason)
	$CanvasLayer/GameOver.show()
	
	get_tree().paused = false


func _on_player_dead(player_id) -> void:
	emit_signal("player_dead", player_id)
	if player_id == my_id:
		# MatchManager.custom_rpc_sync(self, "_rpc_player_dead", [REAS])
		MatchManager.current_match.stop_game(REASON_YOU_DIED)
	else:
		MatchManager.current_match.stop_game(REASON_PLAYER_DIED)
	# players_alive.erase(player_id)
	# if not game_over and players_alive.size() == 0:

	# 	var player_keys = players_alive.keys()
	# 	# emit_signal("game_over", player_keys[0])

func _rpc_player_dead(reason: String) -> void:
	MatchManager.current_match.stop_game(reason)

func _on_MenuButton_pressed():
	if MatchManager.match_mode == MatchManager.MatchMode.SINGLE:
		get_tree().paused = true
	$CanvasLayer/Menu.show()
