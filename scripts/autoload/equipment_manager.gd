extends Node

onready var self_instance = self

const TYPE_SKILL_CASTER = "skill_caster"
const TYPE_BODY_PROTECTER = "body_protector"
const TYPE_MV_BOOSTER = "mv_booster"
const TYPE_ATK_ENHANCER = "atk_enhancer"

var equipment_list: Dictionary = {
	"skill_caster": [],
	"shield": [],
	"mv_booster": [],
	"atk_enhancer": [],
}

var equipped: Dictionary = {
	"skill_caster": null,
	"shield": null,
	"mv_booster": null,
	"atk_enhancer": null,
}

signal equipment_updated(type)
signal equipment_crafted(equipment)
signal equipment_added(equipment)


func _init() -> void:
	var _d := Conn.connect("session_connected", self, "_on_session_created")
	_d = Conn.connect("session_changed", self, "_on_session_changed")


func is_equipped(equipment: Equipment) -> bool:
	return equipment == EquipmentManager.equipped[equipment.type_name]


func equip(equipment: Equipment) -> void:
	if equipment_list[equipment.type_name].has(equipment):
		equipped[equipment.type_name] = equipment
	pass


func get_equipment_list(type_name: String) -> Array:
	if not equipment_list.has(type_name):
		return []
	return equipment_list[type_name]


func parse_equipment(detail: String) -> Equipment:
	var result = JSON.parse(detail).result
	return dict2equipment(result)


func dict2equipment(result: Dictionary) -> Equipment:
	var equipment: Equipment = Equipment.new()
	equipment.raw = result["raw"]
	equipment.type_name = result["type_name"]
	equipment.sub_type = result["sub_type"]
	equipment.tier = result["tier"]
	equipment.stat = []
	for raw_stat in result["stat"]:
		var available = StatManager.get(raw_stat["name"])
		var stat: Stat
		if available:
			stat = available.new(raw_stat["name"], raw_stat["value"])
		else:
			stat = Stat.new(raw_stat["name"], raw_stat["value"])
		equipment.stat.push_back(stat)
	return equipment


func craft_equipment(type: String) -> Equipment:
	var payload = {"type": type}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "craft_equipment", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		print("An error occurred: %s" % response)
		return null
	else:
		print(response.payload)
		var equipment = parse_equipment(response.payload)
		equipment_list[type].append(equipment)
		emit_signal("equipment_crafted", equipment)
		emit_signal("equipment_added", equipment)
		emit_signal("equipment_updated", equipment.type_name)
		return equipment


func get_inventory():
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "get_inventory"), "completed"
	)
	if response.is_exception():
		print("An error occurred: %s" % response)
		return null
	else:
		print(response.payload)
		var result = JSON.parse(response.payload).result

		for type in result.keys():
			for raw_eq in result[type]:
				var equipment = dict2equipment(raw_eq)
				equipment_list[type].append(equipment)


# CALLBACKS
func _on_session_created(_d) -> void:
	get_inventory()


func _on_session_changed(_d) -> void:
	equipment_list = {
		"skill_caster": [],
		"shield": [],
		"mv_booster": [],
		"atk_enhancer": [],
	}
