
# var coin: int = 0
# var soul: int = 0

# var max_hp: float = 100
# var hp: float
# var armour: int = 0
# var regen: int = 0

# var mv_speed: float = 100
# var dash_speed: float = 1000
# var dash_range: float = 250
# var dash_kin: float = 15
# var kinetic: float = 0
# var kin_rate: float = 1
# var kin_thres: float = 50

# var atk_damage: float = 5
# var atk_range: float = 1
# var atk_speed: float = 1
# var fire_rate: float = 1
# var crit_chance: float = 0
# var crit_mul: float = 1.5
# var proj_speed: float = 1
# var proj_num: int = 1
# var proj_pierce: int = 0

# var enlargement: float = 1
# var atk_dir: int = 1


# func _init(is_base: bool = true):
# 	if !is_base:
# 		for prop in get_property_list():
# 			set(prop["name"], 0)


# func dup() -> StatValues:
# 	var new = StatValues.new(true)
# 	for prop in get_property_list():
# 		new.set(prop["name"], get(prop["name"]))
# 	return new


# func to_dict() -> Dictionary:
# 	var result := {}
# 	for prop in get_property_list():
# 		result[prop["name"]] = get(prop["name"])
# 	return result


# func from_dict(dict: Dictionary) -> StatValues:
# 	for prop in dict.keys():
# 		set(prop, dict[prop])
# 	return self
