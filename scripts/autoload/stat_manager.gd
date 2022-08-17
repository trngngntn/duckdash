extends Node

var perc_modf = PercentageModifier
var incr_modf = IncrementModifier

var atk_damamge = perc_modf
var atk_range = perc_modf
var atk_speed = perc_modf
var fire_rate = perc_modf
var crit_chance = perc_modf
var crit_mul = perc_modf
var proj_speed = perc_modf
var proj_num = incr_modf
var proj_pierce = incr_modf

var enlargement = incr_modf
var atk_dir = incr_modf

var max_hp = perc_modf
var armour = incr_modf
var regen = incr_modf

var mv_speed = perc_modf
var dash_range = perc_modf
var dash_kin = perc_modf
var kin_rate = perc_modf

#### Effects
var burn
var freeze
var shock
var knockback
var life_steal

var explode
var implode

var absorption
var reflection
var proj_bounce
var block

var blazing
var frosting
var shifting

var players_stat := {}


class StatValues:
	var coin: int = 0
	var soul: int = 0

	var max_hp: float = 100
	var hp: float
	var armour: int = 0
	var regen: int = 0

	var mv_speed: float = 100
	var dash_speed: float = 1000
	var dash_range: float = 250
	var dash_kin: float = 25
	var kinetic: float = 0
	var kin_rate: float = 10
	var kin_thres: float = 50

	var atk_damamge: float = 5
	var atk_range: float = 1
	var atk_speed: float = 1
	var fire_rate: float = 1
	var crit_chance: float = 0
	var crit_mul: float = 1.5
	var proj_speed: float = 1
	var proj_num: int = 1
	var proj_pierce: int = 0

	var enlargement: float = 1
	var atk_dir: int = 1

	func _init(is_base: bool):
		if !is_base:
			for prop in get_property_list():
				set(prop["name"], 0)

	func dup() -> StatValues:
		var new = StatValues.new(true)
		for prop in get_property_list():
			new.set(prop["name"], get(prop["name"]))
		return new


var current_stat: StatValues
var incr_stat: StatValues
var base_stat: StatValues = StatValues.new(true)
var stat_info_list: Dictionary = {}


func _init() -> void:
	var _d := Conn.connect("session_connected", self, "_on_session_created")


# Calculate new stat from equipped equipment
func calculate_stat() -> void:
	current_stat = base_stat.dup()
	incr_stat = StatValues.new(false)

	print("STAT:  " + str(current_stat.max_hp))

	for type in EquipmentManager.equipped.keys():
		if EquipmentManager.equipped[type] != null:
			for equipment in EquipmentManager.equipped[type]:
				for stat in equipment.stat:
					var s = get(stat.stat_id)
					if s != null && s is Modifier && s.is_stacked:
						var new_val = current_stat.get(stat.stat_id) * stat.get_multiply_value()
						current_stat.set(stat.stat_id, new_val)

				for stat in equipment.stat:
					var s = get(stat.stat_id)
					if s != null && s is Modifier && !s.is_stacked:
						var new_val = current_stat.get(stat.stat_id) + stat.get_add_value()
						incr_stat.set(stat.stat_id, new_val)
	current_stat.hp = current_stat.max_hp


func calculate_stat_from_looting(modifier) -> void:
	if modifier != null && modifier is Modifier:
		if modifier.is_stacked:
			var new_val = current_stat.get(modifier.stat_id) * modifier.get_multiply_value()
			current_stat.set(modifier.stat_id, new_val)
		else:
			var new_val = current_stat.get(modifier.stat_id) + modifier.get_add_value()
			current_stat.set(modifier.stat_id, new_val)


func get_stat(stat_name: String):
	return current_stat.get(stat_name)


# Fetch stat info for displaying items
func fetch_stat_info() -> void:
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "get_stat_info_list", null), "completed"
	)
	if response.is_exception():
		printerr("ERR_FETCH_STAT_INFO_LIST: %s" % response)
		return null
	else:
		print(response.payload)
		var result = JSON.parse(response.payload).result

		if result:
			for raw_stat_info in result:
				stat_info_list[raw_stat_info["id"]] = {}
				stat_info_list[raw_stat_info["id"]]["format"] = raw_stat_info["format"]


# Fetch stat of character calculated by server
func fetch_player_stat() -> void:
	pass


# CALLBACKS
func _on_session_created(_d) -> void:
	fetch_stat_info()
