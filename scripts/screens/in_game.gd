extends Node2D

var Player = preload("res://scenes/character/duck.tscn")

var player_list: Node
var map: Map

var game_started := false
var game_over := false
var players_alive := {}
var players_setup := {}

signal map_generated
signal game_started
signal game_over
signal player_dead(player_id)


func _get_custom_rpc_methods() -> Array:
	return [
		"generate_map",
		"setup",
		"_finish_setup",
		"_start",
	]


func _ready() -> void:
	$CanvasLayer/MoveControl/MoveJoystick.set_snap_step(1)


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
	get_tree().set_pause(true)

	if NakamaMatch.is_network_server():
		$CanvasLayer/TestLabel.text = "SERVER_INSTANCE"
		randomize()
		var map_seed: int = 100
		NakamaMatch.custom_rpc_sync(self, "generate_map", [map_seed])
	elif not map:
		yield(self, "map_generated")

	# if game_started:
	# 	_stop()

	game_started = false
	game_over = false
	players_alive = players

	#reload_map()
	var my_player: Duck
	var my_id: int
	for player_id in players:
		# print("PLAYER: " + str(player_id))
		var other_player = Player.instance()
		other_player.name = "Player" + str(player_id)
		# is current player
		if player_id == NakamaMatch.get_network_unique_id():
			my_id = player_id
			my_player = other_player
			my_player.map_move_joystick($CanvasLayer/MoveControl/MoveJoystick)
			my_player.map_attack_joystick($CanvasLayer/AttackControl/AttackJoystick)

		map.player_cont.add_child(other_player)

		other_player.set_network_master(player_id)
		other_player.set_player_name(players[player_id])
		# other_player.position = map.get_node(
		# 	"PlayerStartPositions/Player" + str(player_id)
		# ).position

		other_player.connect("player_dead", self, "_on_player_dead", [player_id])
		other_player.finish_setup()
		# if not GameState.online_play:
		# 	other_player.player_controlled = true
		# 	other_player.input_prefix = "player" + str(player_id) + "_"
	# var my_id: int = NakamaMatch.get_network_unique_id()
	# var my_player = map.player_cont.get_node(str(my_id))

	my_player.tracking_cam = $GameCamera
	$GameCamera.set_node_tracking(my_player)
	$GameCamera.current = true

	NakamaMatch.custom_rpc_id_sync(self, 1, "_finish_setup", [my_id])


# Records when each player has finished setup so we know when all players are ready.
func _finish_setup(player_id) -> void:
	players_setup[player_id] = players_alive[player_id]
	if players_setup.size() == players_alive.size():
		# Once all clients have finished setup, tell them to start the game.
		NakamaMatch.custom_rpc_sync(self, "_start")


func _start() -> void:
	if map.has_method("map_start"):
		map.map_start()
	emit_signal("game_started")
	get_tree().set_pause(false)


func _stop() -> void:
	queue_free()


func _on_player_dead(player_id) -> void:
	emit_signal("player_dead", player_id)
	players_alive.erase(player_id)
	if not game_over and players_alive.size() == 0:
		game_over = true
		var player_keys = players_alive.keys()
		emit_signal("game_over", player_keys[0])


func _on_DashButton_pressed():
	Input.action_press("move_dash")


func _on_DashButton_released():
	Input.action_release("move_dash")
