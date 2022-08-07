extends Node2D
class_name Map

const TILE_NAV = 2
const TILE_WALL = 1
const TILE_GROUND = 0

const SPAWN_DISTANCE = 600

var _map_data = []
var ground_tile_id = 0
var wall_tile_id = 1
var collision_tile_id = 2

var map_width
var map_height
export var map_padding = 10

var map_full_height: int
var map_full_width: int

onready var nav_tilemap = $Navigation/NavTileMap
onready var wall_tilemap = $YSort/TileMap
onready var ground_tilemap = $Navigation/GroundTileMap

onready var player_cont = $YSort/PlayerCont
var enemy_id = 0


func _get_custom_rpc_methods() -> Array:
	return [
		"spawn_enemy",
	]


func _ready():
	_display_map()
	if not NakamaMatch.is_network_server():
		$MobSpawnerTimer.stop()
		$Navigation/NavUpdateTimer.stop()


func set_data(data: Array) -> void:
	_map_data = data
	map_full_width = data.size() - 1
	map_full_height = data[0].size() - 1
	map_width = map_full_width / 2
	map_height = map_full_height / 2


func set_wall_tile(x: int, y: int) -> void:
	_map_data[x][y] = 1


func set_ground_tile(x: int, y: int) -> void:
	_map_data[x][y] = 0


func get_nearby_tile_count(tile_x: int, tile_y: int, tile_type: int) -> int:
	var tile_count = 0
	for offset_x in range(-1, 1 + 1):
		for offset_y in range(-1, 1 + 1):
			tile_count += 1 if _map_data[tile_x + offset_x][tile_y + offset_y] == tile_type else 0
	return tile_count


func _display_map() -> void:
	#special treatment
	for x in range(0, map_full_width):
		for y in range(0, map_full_height):
			if _map_data[x][y] == TILE_WALL:
				_map_data[x][y - 1] = TILE_WALL
				_map_data[x - 1][y] = TILE_WALL
				_map_data[x - 1][y - 1] = TILE_WALL

	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if _map_data[x + map_width][y + map_height] == 1:
				wall_tilemap.set_cell(x, y, wall_tile_id)
			# else:
			# 	nav_tilemap.set_cell(x, y, TILE_NAV)

	var map_width_padding = map_width + map_padding
	var map_height_padding = map_height + map_padding

	#padding top and bottom edge
	for x in range(-map_width_padding, map_width_padding):
		for y in range(-map_height_padding, -map_height):
			wall_tilemap.set_cell(x, y, wall_tile_id)
			wall_tilemap.set_cell(x, -y - 1, wall_tile_id)

	#padding left and right edge
	for x in range(-map_width_padding, -map_width):
		for y in range(-map_height_padding, map_height_padding):
			wall_tilemap.set_cell(x, y, wall_tile_id)
			wall_tilemap.set_cell(-x - 1, y, wall_tile_id)

	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if (
				wall_tilemap.get_cell(x, y) == TileMap.INVALID_CELL
				|| wall_tilemap.get_cell(x - 1, y) == TileMap.INVALID_CELL
				|| wall_tilemap.get_cell(x, y - 1) == TileMap.INVALID_CELL
				|| wall_tilemap.get_cell(x - 1, y - 1) == TileMap.INVALID_CELL
			):
				ground_tilemap.set_cell(x, y, TILE_GROUND)
				nav_tilemap.set_cell(x, y, TILE_NAV)

	#update bitmask for autotiles
	nav_tilemap.update_bitmask_region(
		Vector2(-map_width_padding, -map_height_padding),
		Vector2(map_width_padding, map_height_padding)
	)
	ground_tilemap.update_bitmask_region(
		Vector2(-map_width_padding, -map_height_padding),
		Vector2(map_width_padding, map_height_padding)
	)
	wall_tilemap.update_bitmask_region(
		Vector2(-map_width_padding, -map_height_padding),
		Vector2(map_width_padding, map_height_padding)
	)


var count = 0


func _on_MobSpawnerTimer_timeout():
	
	if get_tree().get_nodes_in_group("enemy").size() > 100:
		return
	for player in player_cont.get_children():
		spawn_enemy_around_player(player, 0)


func spawn_enemy_around_player(player: Duck, times: int) -> void:
	print("SPAWN")
	if times == 50:
		return
	var rand_pos: Vector2 = (
		(Vector2(2 * randf() - 1, 2 * randf() - 1).normalized() * SPAWN_DISTANCE)
		+ player.position
	)
	var tile_pos: Vector2 = ground_tilemap.world_to_map(ground_tilemap.to_local(rand_pos))
	if ground_tilemap.get_cell(tile_pos.x, tile_pos.y) == TileMap.INVALID_CELL:
		spawn_enemy_around_player(player, times + 1)
		return
	for other_player in player_cont.get_children():
		if (
			other_player != player
			&& rand_pos.distance_squared_to(other_player.position) < SPAWN_DISTANCE * SPAWN_DISTANCE
		):
			spawn_enemy_around_player(player, times + 1)
			return
	NakamaMatch.custom_rpc_sync(self, "spawn_enemy", [rand_pos, player.name, enemy_id])
	enemy_id += 1


#### REMOTE FUNCTIONS
func spawn_enemy(position: Vector2, target_player_id: String, id: int) -> void:
	if not NakamaMatch.is_network_server():
		print("REMOTE_SPAWN")
	var l = preload("res://scenes/enemies/enemy_slime.tscn")
	var enemy = l.instance().init($Navigation, player_cont.get_node(target_player_id), $ForceUpdateTimer)
	enemy.position = position
	enemy.name = "Enemy" + str(id)
	$YSort.add_child(enemy)
	enemy.add_to_group("enemy")
