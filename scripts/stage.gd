extends Node2D

export var map_width = 30
export var map_height = 20
export var map_padding = 10

export var threshold = 53

export var mob_spawn_range = 1200
export var max_enemies_spawn = 120
export var enemies_spawn_rate = 1

const TILE_WALL = 1
const TILE_GROUND = 0

var map = []
var ground_tile_id = 0
var wall_tile_id = 1
var collision_tile_id = 2

onready var wall_tilemap = $YSort/TileMap
onready var ground_tilemap = $Navigation/GroundTileMap
onready var map_full_width = map_width * 2 + 1
onready var map_full_height = map_height * 2 + 1


func _ready():
	randomize()
	#_generate_map()
	map.resize(map_full_width + 1)
	for i in range (0, map_full_width + 1):
		map[i] = []
		map[i].resize(map_full_height + 1)
	_gen_map_using_rand()
	_display_map()


func _gen_map_using_rand() -> void:
	for x in range(0, map_full_width):
		for y in range(0, map_full_height):
			map[x][y] = TILE_GROUND if (randi() % 100 < threshold) else TILE_WALL
	_smooth_map()

func _gen_map_using_noise() -> void:
	pass


func _smooth_map() -> void:
	for x in range(0, map_full_width):
		for y in range(0, map_full_height):
			map[x][y] = TILE_WALL if _get_nearby_tile_count(x, y, TILE_WALL) > 4 else TILE_GROUND


func _get_nearby_tile_count(tile_x: int, tile_y: int, tile_type: int) -> int:
	var tile_count = 0
	for offset_x in range(-1, 1 + 1):
		for offset_y in range(-1, 1 + 1):
			tile_count += 1 if map[tile_x + offset_x][tile_y + offset_y] == tile_type else 0
	return tile_count


func _display_map() -> void:
	#special treatment
	for x in range(0, map_full_width):
		for y in range(0, map_full_height):
			if map[x][y] == TILE_WALL:
				map[x][y - 1] = TILE_WALL
				map[x - 1][y] = TILE_WALL
				map[x - 1][y - 1] = TILE_WALL

	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if map[x + map_width][y + map_height] == 1:
				wall_tilemap.set_cell(x, y, wall_tile_id)

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
				ground_tilemap.set_cell(x, y, 0)
		

	#update bitmask for autotiles
	ground_tilemap.update_bitmask_region(
		Vector2(-map_width_padding, -map_height_padding), Vector2(map_width_padding, map_height_padding)
	)
	wall_tilemap.update_bitmask_region(
		Vector2(-map_width_padding, -map_height_padding), Vector2(map_width_padding, map_height_padding)
	)


func _generate_map() -> void:
	var noise = OpenSimplexNoise.new()

	noise.seed = randi()
	noise.octaves = 3
	noise.period = 8
	noise.persistence = .35

	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if noise.get_noise_2d(x, y) > 0.25:
				wall_tilemap.set_cell(x, y, wall_tile_id)
				wall_tilemap.set_cell(x - 1, y, wall_tile_id)
				wall_tilemap.set_cell(x, y - 1, wall_tile_id)
				wall_tilemap.set_cell(x - 1, y - 1, wall_tile_id)

	#padding top and bottom edge
	for x in range(-map_full_width, map_full_width):
		for y in range(-map_full_height, -map_height):
			wall_tilemap.set_cell(x, y, wall_tile_id)
			wall_tilemap.set_cell(x, -y - 1, wall_tile_id)

	#padding left and right edge
	for x in range(-map_full_width, -map_width):
		for y in range(-map_full_height, map_full_height):
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
				ground_tilemap.set_cell(x, y, 0)

	#update bitmask for autotiles
	ground_tilemap.update_bitmask_region(
		Vector2(-map_full_width, -map_full_height), Vector2(map_full_width, map_full_height)
	)
	wall_tilemap.update_bitmask_region(
		Vector2(-map_full_width, -map_full_height), Vector2(map_full_width, map_full_height)
	)

	#adding collision tiles
	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if ground_tilemap.get_cell(x, y) != TileMap.INVALID_CELL:
				for x_offset in range(-1, 2):
					for y_offset in range(-1, 2):
						if ground_tilemap.get_cell(x + x_offset, y + y_offset) != 0:
							ground_tilemap.set_cell(x + x_offset, y + y_offset, 2)


func _on_MobSpawnerTimer_timeout():
	if get_tree().get_nodes_in_group("enemies").size() < max_enemies_spawn:
		var rand_point = (
			get_tree().get_nodes_in_group("duck").front().position
			+ Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * mob_spawn_range
		)
		while (
			$YSort/TileMap.get_cell(floor((rand_point.x - 64) / 128), floor(rand_point.y / 128))
			!= TileMap.INVALID_CELL
		):
			rand_point = (
				get_tree().get_nodes_in_group("duck").front().position
				+ Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * mob_spawn_range
			)
		var mob = preload("res://scenes/enemies/enemy_slime.tscn").instance()
		mob.position = rand_point
		$YSort.add_child(mob)
		mob.add_to_group("enemies")
