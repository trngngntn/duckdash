extends Node2D

export var map_width = 30
export var map_height = 20
export var map_padding = 10

export var mob_spawn_range = 1200
export var max_enemies_spawn = 120

func _ready():
	print(get_children())
	_generate_map()

func _generate_map():
	var noise = OpenSimplexNoise.new()
	
	noise.seed = randi()
	noise.octaves = 3
	noise.period = 8
	noise.persistence = .35
	
	var map_full_width = map_width + map_padding
	var map_full_height = map_height + map_padding
	var wall_tilemap = $YSort/TileMap
	var ground_tilemap = $Navigation/GroundTileMap
	var wall_tile_id = 1;
	
	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if noise.get_noise_2d(x, y) > 0.25:
				wall_tilemap.set_cell(x ,y , wall_tile_id)
				wall_tilemap.set_cell(x - 1 ,y, wall_tile_id)
				wall_tilemap.set_cell(x ,y - 1 , wall_tile_id)
				wall_tilemap.set_cell(x - 1 ,y - 1, wall_tile_id)
				
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
			if wall_tilemap.get_cell(x,y) == TileMap.INVALID_CELL || wall_tilemap.get_cell(x - 1,y)  == TileMap.INVALID_CELL ||  wall_tilemap.get_cell(x,y - 1)  == TileMap.INVALID_CELL ||  wall_tilemap.get_cell(x - 1,y - 1)  == TileMap.INVALID_CELL:
				ground_tilemap.set_cell(x ,y , 0)
			
	#update bitmask for autotiles
	ground_tilemap.update_bitmask_region(Vector2(-map_full_width,-map_full_height), Vector2(map_full_width,map_full_height))
	wall_tilemap.update_bitmask_region(Vector2(-map_full_width,-map_full_height), Vector2(map_full_width,map_full_height))
	
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
		var rand_point = get_tree().get_nodes_in_group("duck").front().position + Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * mob_spawn_range
		while $YSort/WallTileMap.get_cell(floor((rand_point.x - 64) / 128), floor(rand_point.y / 128)) != TileMap.INVALID_CELL:
			rand_point = get_tree().get_nodes_in_group("duck").front().position + Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * mob_spawn_range
		var mob = preload("res://scenes/enemies/enemy_slime.tscn").instance()
		mob.position = rand_point
		$YSort.add_child(mob)
		mob.add_to_group("enemies")
