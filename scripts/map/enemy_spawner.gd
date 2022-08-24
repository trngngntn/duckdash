class_name EnemySpawner extends Node

const SPAWN_DISTANCE = 600

const ENEMY_SLIME = preload("res://scenes/enemies/enemy_slime.tscn")
const ENEMY_BEE = preload("res://scenes/enemies/enemy_bee.tscn")

const ENEMY_TYPE = [ENEMY_SLIME, ENEMY_BEE]
# enum EnemyType{
# 	SLIME = 0,
# 	BEE = 1
# }
const ENEMY_DIST_LIST = [5, 1]

export var enemy_limit: int = 120
export var enabled: bool = true

var spawn_rate: float = 1
var name_pool: Array

onready var map = get_parent()


func _get_custom_rpc_methods() -> Array:
	return [
		"_rpc_sync_spawn_enemy",
	]


func _init():
	pass


func _ready():
	var ingame = MatchManager.current_match.in_game_node
	ingame.connect("game_started", self, "_on_game_started")
	if MatchManager.is_network_server():
		for i in range(0, enemy_limit):
			name_pool.append("E" + str(i))


func _on_host_migrating(new_host: int):
	if MatchManager.is_master(new_host):
		pass


func _on_game_started() -> void:
	if MatchManager.is_network_server() && enabled:
		$Timer.start()
		$SpawnTimer.wait_time = 2
		$SpawnTimer.start()


func _on_Timer_timeout():
	spawn_rate += 1
	if spawn_rate == 20:
		$Timer.stop()
	$SpawnTimer.wait_time = 2.0 / spawn_rate


func _on_SpawnTimer_timeout():
	for player in get_tree().get_nodes_in_group("player"):
		if name_pool.size() > 0:
			var _name = name_pool.front()
			name_pool.pop_front()
			spawn_enemy_around_player(player, _name, 0)
		else:
			return


func spawn_enemy_around_player(player: Duck, _name: String, times: int) -> void:
	if times == 50:
		name_pool.push_back(_name)

	var rand_pos: Vector2 = (
		(Vector2(2 * randf() - 1, 2 * randf() - 1).normalized() * SPAWN_DISTANCE)
		+ player.position
	)
	var map_dat = map.ground_tilemap
	var tile_pos: Vector2 = map_dat.world_to_map(map_dat.to_local(rand_pos))
	if map_dat.get_cell(tile_pos.x, tile_pos.y) == TileMap.INVALID_CELL:
		spawn_enemy_around_player(player, _name, times + 1)
		return
	for other_player in map.player_cont.get_children():
		if (
			other_player != player
			&& rand_pos.distance_squared_to(other_player.position) < SPAWN_DISTANCE * SPAWN_DISTANCE
		):
			spawn_enemy_around_player(player, _name, times + 1)
			return
	var type = Randomizer.rand_with_int_chance_arr(ENEMY_DIST_LIST)
	MatchManager.custom_rpc_sync(
		self, "_rpc_sync_spawn_enemy", [rand_pos, type, player.name, _name]
	)


func free_enemy(enemy: Enemy):
	map.cont.remove_child(enemy)
	if MatchManager.is_network_server():
		name_pool.push_back(enemy.name)
	enemy.queue_free()
	# print("FREEING SHITS")
	# ENEMY_LIST[enemy.TYPE]["pool"].append(enemy)
	# enemy.remove_from_group("enemy")
	# map.cont.remove_child(enemy)


func _rpc_sync_spawn_enemy(position: Vector2, type: int, username: String, _name: String) -> void:
	var enemy = ENEMY_TYPE[type].instance().init(
		self, map.player_cont.get_node(username), _name, position
	)
	map.cont.add_child(enemy)
	# print("SPAWNED: " + str(enemy.get_path()))
	enemy.add_to_group("enemy")
