extends Node

onready var self_instance = self

const TYPE_SKILL_CASTER = "skill_caster"
const TYPE_ENHANCER = "enhancer"

var equipment_list: Dictionary = {
	"skill_caster": [],
	"enhancer": [],
}

var equipped: Dictionary = {
	"skill_caster": [],
	"enhancer": [],
}

signal equipment_updated(type)
signal equipment_crafted(equipment)
signal equipment_added(equipment)

signal equipment_equipped(type, equipment)
signal got_equipment_detail(equipment)
# signal equipment_unequipped(type, equipment)


func _init() -> void:
	var _d := Conn.connect("session_connected", self, "_on_session_created")
	_d = Conn.connect("session_changed", self, "_on_session_changed")


func is_equipped(equipment: Equipment) -> bool:
	return EquipmentManager.equipped[equipment.type_name].has(equipment)


func is_sellable(equipment: Equipment) -> bool:
	return equipment.tier != "BASIC"


func equip(equipment: Equipment, pos: int = 0) -> void:
	match equipment.type_name:
		TYPE_SKILL_CASTER:
			equipped[TYPE_SKILL_CASTER] = [equipment]
		TYPE_ENHANCER:
			if pos >= equipped[TYPE_ENHANCER].size():
				equipped[TYPE_ENHANCER].append(equipment)
			else:
				equipped[TYPE_ENHANCER][pos] = equipment
	emit_signal("equipment_equipped", equipment.type_name, equipment, pos)


func unequip(equipment: Equipment) -> void:
	match equipment.type_name:
		TYPE_SKILL_CASTER:
			return
		TYPE_ENHANCER:
			equipped[TYPE_ENHANCER].erase(equipment)
			# emit_signal("equipment_equipped", equipment.type_name, equipment)


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
		var stat
		if available:
			stat = available.new(raw_stat["name"], raw_stat["value"])
		else:
			stat = Stat.new(raw_stat["name"], raw_stat["value"])
		equipment.stat.push_back(stat)

	match equipment.type_name:
		"skill_caster":
			return SkillCaster.new(equipment)
		"enhancer":
			return Enhancer.new(equipment)
	return equipment


func craft_equipment(type: String) -> Equipment:
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"type": type}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "craft_equipment", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		# print("An error occurred: %s" % response)
		return null
	else:
		# print(response.payload)
		var equipment = parse_equipment(response.payload)
		match type:
			"skill_caster":
				equipment = SkillCaster.new(equipment)
			"enhancer":
				equipment = Enhancer.new(equipment)

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
		# print(response.payload)
		var result = JSON.parse(response.payload).result

		for type in result.keys():
			for raw_eq in result[type]:
				var equipment = dict2equipment(raw_eq)
				match type:
					"skill_caster":
						equipment_list[type].append(SkillCaster.new(equipment))
					"enhancer":
						equipment_list[type].append(Enhancer.new(equipment))

func GetEquipmentDetail(raw: String) -> Equipment:
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"raw": raw}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "get_equipment_by_raw", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null
	else:
		var equipment = parse_equipment(response.payload)
		return equipment


func reload_inventory():
	equipment_list = {
		"skill_caster": [],
		"enhancer": [],
	}
	get_inventory()


# CALLBACKS
func _on_session_created(_d) -> void:
	get_inventory()


func _on_session_changed(_d) -> void:
	equipment_list = {
		"skill_caster": [],
		"enhancer": [],
	}