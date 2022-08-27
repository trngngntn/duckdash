extends Node2D
class_name Map

const TILE_NAV = 2
const TILE_WALL = 1
const TILE_GROUND = 0

var drop_count = 0

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

onready var nav = $Navigation
onready var cont = $YSort

onready var player_cont = $YSort/PlayerCont


func _ready():
	pause_mode = Node.PAUSE_MODE_STOP
	_display_map()
	if not MatchManager.is_network_server():
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
