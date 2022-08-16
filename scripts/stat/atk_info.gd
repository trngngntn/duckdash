class_name AtkInfo

var dmg: float
var eff: Array


func create(_dmg: float, _eff: Array) -> AtkInfo:
	dmg = _dmg
	eff = _eff
	return self


func to_dict() -> Dictionary:
	return {"dmg": dmg, "eff": eff}


func from_dict(dict: Dictionary):
	dmg = dict["dmg"]
	eff = dict["eff"]
	return self
