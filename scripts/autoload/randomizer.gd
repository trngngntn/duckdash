extends Node

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
