extends Node

func get_crit_tier(chance: float, base_mul: float) -> Dictionary:
	var next_critier = chance - floor(chance)
	var rand: float = randf()
	
	if rand < next_critier:
		var mul = get_multipier(floor(chance) + 1, base_mul)
		
		return {
			"tier": floor(chance) + 1,
			"mul": mul
		}
	else:
		var mul = get_multipier(floor(chance), base_mul)
		return {
			"tier": floor(chance),
			"mul": mul
		}

func get_multipier(tier: int, base_mul: float):
	return 1 + tier * (base_mul - 1)

func rand_loot_table(loot_tbl: Dictionary) -> Array:
	randomize()
	var offset: float = randf()
	var result: Array = []
	for item_name in loot_tbl.keys():
		var rand: float = randf() - offset
		if rand < 0:
			rand += 1.0
		for chance in loot_tbl[item_name]:
			if rand <= chance:
				result.append(item_name)
			else:
				break
	return result


func rand_with_int_chance_arr(arr: Array) -> int:
	var cumulative_arr: Array = []
	var temp: int = 0
	for val in arr:
		temp += val
		cumulative_arr.append(val)

	var offset: int = randi() % temp
	var rand_val = (randi() % temp + temp - offset) % temp

	for i in range(0, cumulative_arr.size()):
		if cumulative_arr[i] > rand_val:
			return i

	return -1
