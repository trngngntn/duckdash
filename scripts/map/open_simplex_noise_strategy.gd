extends MapGenStrategy

var map = []

func execute(map_width : int, map_height: int):
	_map_full_width = map_width * 2 + 1
	_map_full_height = map_height * 2 + 1

	randomize()

	var noise = OpenSimplexNoise.new()

	noise.seed = randi()
	noise.octaves = 3
	noise.period = 8
	noise.persistence = .35

	for x in range(-map_width, map_width + 1):
		for y in range(-map_height, map_height + 1):
			if noise.get_noise_2d(x, y) > 0.25:
				map[x][y] = 1
				# map[x-1][y] = 1
				# map[x][y-1] = 1
				# map[x-1][y-1] = 1