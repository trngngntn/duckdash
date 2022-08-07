extends Modifier
class_name PercentageModifier

func _init(_stat_id: String, _value: int).(_stat_id,_value):
	pass

func get_multiply_value() -> float:
    return float(value) / 100