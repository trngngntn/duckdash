extends Node

onready var self_instance = self

const TYPE_SKILL_CASTER = "skill_caster"
const TYPE_BODY_PROTECTER = "body_protector"
const TYPE_MV_BOOSTER = "mv_booster"
const TYPE_ATK_ENHANCER = "atk_enhancer"

var equipment_list: Dictionary = {
	"skill_caster": [],
	"body_protector": [],
	"mv_booster": [],
	"atk_enhancer": [],
}

var equipped: Dictionary = {
	"skill_caster": null,
	"body_protector": null,
	"mv_booster": null,
	"atk_enhancer": null,
}

signal equipment_crafted(equipment)


func equip(equipment: Equipment):
	if equipment_list[equipment.type_name].has(equipment):
		equipped[equipment.type_name] = equipment
	pass


func get_equipment_list(type_name: String) -> Array:
	if not equipment_list.has(type_name):
		return []
	return equipment_list[type_name]


func parse_equipment(detail: String) -> Dictionary:
	var equipment: Equipment = Equipment.new()
	var result = JSON.parse(detail).result
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
	return {"raw": "", "equipment": equipment}


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
		var parse_result = parse_equipment(response.payload)
		emit_signal("equipment_crafted", parse_result["equipment"])
		equipment_list[type].append(parse_result["equipment"])
		return parse_result["equipment"]
