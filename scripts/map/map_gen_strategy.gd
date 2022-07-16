extends Node

class_name MapGenStrategy

var _map_full_width : int
var _map_full_height : int

func _map(map_width : int, map_height: int) -> Array:
	_map_full_width = map_width * 2 + 1
	_map_full_height = map_height * 2 + 1
	var map = []
	map.resize(_map_full_width + 1)
	for i in range(0, _map_full_width + 1):
		map[i] = []
		map[i].resize(_map_full_height + 1)
	return map

func generate(_map_seed: int, _map_width : int, _map_height: int) -> Array:
	return []
