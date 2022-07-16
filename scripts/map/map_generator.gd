extends Node

class_name MapGenerator

var _strategy: MapGenStrategy
var Map = preload("res://scenes/map/map.tscn")

func set_strategy(strategy: MapGenStrategy) -> void:
	_strategy = strategy

func generate_map(map_seed: int) -> Map:
	var map_data : Array = _strategy.generate(map_seed, 30, 30)
	var map = Map.instance()
	map.set_data(map_data)
	return map

