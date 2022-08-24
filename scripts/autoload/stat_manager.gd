extends Node

var perc_modf = PercentageModifier
var incr_modf = IncrementModifier

var atk_damage = perc_modf
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

signal stat_change(name, change_value, new_value)
signal stat_change_peer_id(peer_id, name, change_value, new_value)
signal stat_calculated


class StatValues:
	var skill

	var coin: int = 0
	var soul: int = 0

	var max_hp: float = 1000000
	var hp: float
	var armour: int = 0
	var regen: int = 0

	var mv_speed: float = 100
	var dash_speed: float = 1000
	var dash_range: float = 250
	var dash_kin: float = 15
	var kinetic: float = 0
	var kin_rate: float = 1
	var kin_thres: float = 50

	var atk_damage: float = 5
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

	func _init(is_base: bool = true):
		if !is_base:
			for prop in get_property_list():
				set(prop["name"], 0)

	func dup() -> StatValues:
		var new = StatValues.new(true)
		for prop in get_property_list():
			new.set(prop["name"], get(prop["name"]))
		return new

	func to_dict() -> Dictionary:
		var result: Dictionary = {}
		for prop in get_property_list():
			if (
				prop["name"] != "Reference"
				&& prop["name"] != "script"
				&& prop["name"] != "Script Variables"
			):
				result[prop["name"]] = get(prop["name"])
		return result

	func from_dict(dict: Dictionary) -> StatValues:
		for prop in dict.keys():
			set(prop, dict[prop])
		return self


var current_stat: StatValues
var incr_stat: StatValues
var base_stat: StatValues = StatValues.new()
var stat_info_list: Dictionary = {}


func _get_custom_rpc_methods() -> Array:
	return ["_force_update_stat"]


func _init() -> void:
	Conn.connect("session_connected", self, "_on_session_created")
	Updater.connect("timeout", self, "_on_update_timeout")


# Calculate new stat from equipped equipment
func calculate_stat() -> void:
	current_stat = base_stat.dup()
	incr_stat = StatValues.new(false)

	##  Get attack skill from equipment
	var skill_caster = EquipmentManager.equipped["skill_caster"][0]
	var inst = SkillCaster.SUB_TYPE[skill_caster.sub_type]["res"].instance()

	current_stat.skill = skill_caster.sub_type
	current_stat.atk_damage *= inst.mul_atk
	current_stat.atk_speed *= inst.mul_atk_speed
	current_stat.fire_rate *= inst.mul_atk_speed

	## Calculate stats from equipment

	for type in EquipmentManager.equipped.keys():
		if EquipmentManager.equipped[type].size() > 0:
			for equipment in EquipmentManager.equipped[type]:
				for stat in equipment.stat:
					if stat is Modifier && stat.is_stacked:
						var new_val = current_stat.get(stat.stat_id) * stat.get_multiply_value()
						current_stat.set(stat.stat_id, new_val)

				for stat in equipment.stat:
					if stat is Modifier && !stat.is_stacked:
						var new_val = current_stat.get(stat.stat_id) + stat.get_add_value()
						incr_stat.set(stat.stat_id, new_val)

	current_stat.hp = current_stat.max_hp
	players_stat[MatchManager.current_match.self_peer_id] = current_stat
	emit_signal("stat_calculated")


func update_stat(peer_id: int, stat_name: String, change_value) -> void:
	if not MatchManager.current_match:
		return

	var stat = players_stat[peer_id].get(stat_name)
	if stat == null:
		return
	elif stat_name == "hp":
		change_value = clamp(change_value, -stat, players_stat[peer_id].max_hp - stat)
	elif stat_name == "kinetic":
		change_value = clamp(
			change_value,
			-players_stat[peer_id].kin_thres - stat,
			players_stat[peer_id].kin_thres - stat
		)
	var new_value = stat + change_value
	players_stat[peer_id].set(stat_name, new_value)

	if MatchManager.is_master(peer_id):
		emit_signal("stat_change", stat_name, change_value, new_value)
	emit_signal("stat_change_peer_id", peer_id, stat_name, change_value, new_value)

	if stat_name == "max_hp" && new_value < players_stat[peer_id].hp:
		update_stat(peer_id, "hp", new_value - players_stat[peer_id].hp)


#CLIENT-ONLY
# Update players stat from server
func _force_update_stat(peer_id: int, stat: Dictionary) -> void:
	for prop in stat.keys():
		if stat.get(prop) != players_stat[peer_id].get(prop):
			update_stat(peer_id, prop, stat.get(prop) - players_stat[peer_id].get(prop))


# SERVER-ONLY
# Update players stat to client
func _on_update_timeout() -> void:
	if MatchManager.is_network_server():
		for peer_id in players_stat.keys():
			MatchManager.custom_rpc(
				self, "_force_update_stat", [peer_id, players_stat[peer_id].to_dict()]
			)


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
		# print(response.payload)
		var result = JSON.parse(response.payload).result

		if result:
			for raw_stat_info in result:
				stat_info_list[raw_stat_info["id"]] = {}
				stat_info_list[raw_stat_info["id"]]["format"] = raw_stat_info["format"]


# TO-DO: Implement server calculated player stat
# Fetch stat of character calculated by server
# func fetch_player_stat() -> void:
# 	pass


# CALLBACKS
func _on_session_created(_d) -> void:
	fetch_stat_info()
