extends Navigation2D

const UPDATE_THRESHOLD = 90000
var point = preload("res://scenes/map/point.tscn")
var path_list = []
onready var timer = $NavUpdateTimer
var node2d

func normalize_path(path: PoolVector2Array) -> PoolVector2Array:
	remove_child(node2d)
	node2d = Node2D.new()
	add_child(node2d)
	for i in range(0, path.size()):
		path[i] = $GroundTileMap.map_to_world($GroundTileMap.world_to_map(path[i]))
		var p = point.instance()
		p.position = path[i]
		node2d.add_child(p)
	return path

func get_cached_simple_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	for path in path_list:
		if from.distance_squared_to(path[0]) < UPDATE_THRESHOLD:
			# 
			return path
	var new_path = normalize_path(get_simple_path(from, to))
	path_list.append(new_path)
	# print("NEW_PATH: " + str(path_list.size()))
	return new_path

func force_update_path(path: PoolVector2Array,from: Vector2, to: Vector2) -> PoolVector2Array:
	path_list.erase(path)
	return get_cached_simple_path(from, to)