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


func _get_custom_rpc_methods() -> Array:
	return [
		"generate_map",
		"setup",
		"_finish_setup",
		"_start",
	]


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	$CanvasLayer/MoveControl/MoveJoystick.set_snap_step(1)
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

	# if game_started:
	# 	_stop()

	game_started = false
	game_over = false
	players_alive = players

	#reload_map()

	for player_id in players:
		var player = Player.instance()
		player.name = "Player" + str(player_id)

		map.player_cont.add_child(player)
		player.set_network_master(player_id)
		player.set_player_name(players[player_id])
		# other_player.position = map.get_node(
		# 	"PlayerStartPositions/Player" + str(player_id)
		# ).position

		player.connect("dead", self, "_on_player_dead", [player_id])
		player.add_to_group("player")
		if player_id == MatchManager.get_network_unique_id():
			my_id = player_id
			my_player = player
#		else:
#			player.finish_setup()

	# setup for current player
	StatManager.calculate_stat()

	my_player.connect("hp_changed", hp_bar, "_on_player_hp_changed")
	my_player.connect("hp_max_changed", hp_bar, "_on_player_hp_max_changed")
	hp_bar.value = StatManager.get_stat("max_hp")

	my_player.map_move_joystick($CanvasLayer/MoveControl/MoveJoystick)
	my_player.map_attack_joystick($CanvasLayer/AttackControl/AttackJoystick)

	my_player.tracking_cam = $GameCamera
	$GameCamera.set_node_tracking(my_player)
	$GameCamera.current = true

	var my_player_stat = StatManager.current_stat

	StatManager.players_stat[my_id] = my_player_stat

#	my_player.finish_setup()

	# notify other players
	print("My ID: " + str(my_id))
	print("My Stat: " + str(my_player_stat))
	MatchManager.custom_rpc_id_sync(self, 1, "_finish_setup", [my_id, my_player_stat])

	for player in get_tree().get_nodes_in_group("player"):
		player.finish_setup()


# Records when each player has finished setup so we know when all players are ready.
func _finish_setup(player_id, player_stat) -> void:
	StatManager.players_stat[player_id] = player_stat
	players_setup[player_id] = players_alive[player_id]
	if players_setup.size() == players_alive.size():
		# Once all clients have finished setup, tell them to start the game.
		MatchManager.custom_rpc_sync(self, "_start")


func _start() -> void:
	if map.has_method("map_start"):
		map.map_start()
	emit_signal("game_started")
	get_tree().paused = false


func _stop() -> void:
	queue_free()


func _on_game_over(reason: String) -> void:
	game_over = true
	print("ENDGAMAE")
	$CanvasLayer/GameOver.set_reason(reason)
	$CanvasLayer/GameOver.show()
	map.queue_free()
	get_tree().paused = false


func _on_player_dead(player_id) -> void:
	emit_signal("player_dead", player_id)

	if player_id == my_id:
		MatchManager.current_match.stop_game(REASON_YOU_DIED)
	else:
		MatchManager.current_match.stop_game(REASON_PLAYER_DIED)
	# players_alive.erase(player_id)
	# if not game_over and players_alive.size() == 0:

	# 	var player_keys = players_alive.keys()
	# 	# emit_signal("game_over", player_keys[0])


func _on_DashButton_pressed():
	Input.action_press("move_dash")


func _on_DashButton_released():
	Input.action_release("move_dash")


func _on_MenuButton_pressed():
	if MatchManager.match_mode == MatchManager.MatchMode.SINGLE:
		get_tree().paused = true
	$CanvasLayer/Menu.show()
