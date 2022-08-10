extends Modifier
class_name IncrementModifier

func _init(_stat_id: String, _value: int).(_stat_id,_value):
	is_stacked = false

func get_add_value() -> int:
	return value
