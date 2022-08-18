class_name AtkInfo

var from_peer: int
var to_peer: int
var dmg: float
var eff: Array


func create(_from_peer: int, _to_peer: int, _dmg: float, _eff: Array) -> AtkInfo:
	from_peer = _from_peer
	to_peer = _to_peer
	dmg = _dmg
	eff = _eff
	return self


func to_dict() -> Dictionary:
	return {"from": from_peer, "to": to_peer, "dmg": dmg, "eff": eff}


func from_dict(dict: Dictionary):
	from_peer = dict["from"]
	to_peer = dict["to"]
	dmg = dict["dmg"]
	eff = dict["eff"]
	return self
