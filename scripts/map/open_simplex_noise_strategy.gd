extends MapGenStrategy
class_name OpenSimplexNoiseStrategy

func generate(map_seed: int, map_width : int, map_height: int) -> Array:
	var map : Array = _map(map_width, map_height)

	var noise = OpenSimplexNoise.new()
	noise.seed = map_seed
	noise.octaves = 3
	noise.period = 8
	noise.persistence = .35

	for x in range(0, _map_full_width):
		for y in range(0, _map_full_height):
			if noise.get_noise_2d(x, y) > 0.25:
				map[x][y] = 1

	return map