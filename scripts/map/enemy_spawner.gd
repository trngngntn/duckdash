extends Node

const SPAWN_DISTANCE = 600

const ENEMY ={}

export var enemy_limit: int = 120
export var enabled: bool = true

var spawn_rate: float = 1

var enemy_id = 0

onready var map = get_parent()


func _get_custom_rpc_methods() -> Array:
	return [
		"_rpc_sync_spawn_enemy",
	]


func _ready():
	var ingame = MatchManager.current_match.in_game_node
	ingame.connect("game_started", self, "_on_game_started")


func _on_host_migrating(new_host: int):
	if MatchManager.is_master(new_host):
		pass


func _on_game_started() -> void:
	if MatchManager.is_network_master() && enabled:
		$Timer.start()
		$SpawnTimer.wait_time = 2
		$SpawnTimer.start()


func _on_Timer_timeout():
	spawn_rate += 1
	if spawn_rate == 20:
		$Timer.stop()
	$SpawnTimer.wait_time = 2.0 / spawn_rate


func _on_SpawnTimer_timeout():
	if get_tree().get_nodes_in_group("enemy").size() >= 120:
		return
	for player in get_tree().get_nodes_in_group("player"):
		spawn_enemy_around_player(player, 0)


func spawn_enemy_around_player(player: Duck, times: int) -> void:
	# print("SPAWN")
	if times == 50:
		return
	# print("PLAYER" + str(player))
	var rand_pos: Vector2 = (
		(Vector2(2 * randf() - 1, 2 * randf() - 1).normalized() * SPAWN_DISTANCE)
		+ player.position
	)
	var map_dat = map.ground_tilemap
	var tile_pos: Vector2 = map_dat.world_to_map(map_dat.to_local(rand_pos))
	if map_dat.get_cell(tile_pos.x, tile_pos.y) == TileMap.INVALID_CELL:
		spawn_enemy_around_player(player, times + 1)
		return
	for other_player in map.player_cont.get_children():
		if (
			other_player != player
			&& rand_pos.distance_squared_to(other_player.position) < SPAWN_DISTANCE * SPAWN_DISTANCE
		):
			spawn_enemy_around_player(player, times + 1)
			return
	MatchManager.custom_rpc_sync(self, "_rpc_sync_spawn_enemy", [rand_pos, player.name, enemy_id])
	enemy_id += 1


func _rpc_sync_spawn_enemy(position: Vector2, peer_id: String, id: int) -> void:
	var l = preload("res://scenes/enemies/enemy_slime.tscn")
	var enemy = l.instance().init(map.nav, map.player_cont.get_node(peer_id))
	enemy.position = position
	enemy.name = "Enemy" + str(id)
	map.cont.add_child(enemy)
	enemy.add_to_group("enemy")
