class_name AtkInfo

var from_peer: int
var to_peer: int
var dmg: float
var crit_tier: int
var eff: Array


func create(_from_peer: int, _to_peer: int, _dmg: float, _eff: Array, crit_dict: Dictionary) -> AtkInfo:
	from_peer = _from_peer
	to_peer = _to_peer
	dmg = _dmg * crit_dict["mul"]
	eff = _eff
	if crit_dict.has("tier"):
		crit_tier = crit_dict["tier"]
	return self


func to_dict() -> Dictionary:
	return {"from": from_peer, "to": to_peer, "dmg": dmg, "eff": eff, "crit_tier": crit_tier}


func from_dict(dict: Dictionary):
	from_peer = dict["from"]
	to_peer = dict["to"]
	dmg = dict["dmg"]
	eff = dict["eff"]
	crit_tier = dict["crit_tier"]
	return self
