extends Stat
class_name Modifier

var is_stacked: bool = true

func _init(_stat_id: String, _value: int).(_stat_id,_value):
	pass

func get_multiply_value() -> float:
	return 1.0

func get_add_value():
	return 0
