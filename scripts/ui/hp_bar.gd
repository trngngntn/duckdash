extends NinePatchRect

var value: float = 0 setget _set_value
var max_value: float = -1 setget _set_max_value

func _ready():
	self.max_value = 100
	self.value = 0

func _set_max_value(_value: float) -> void:
	max_value = _value
	_update_value()

func _set_value(_value: float) -> void:
	value = _value
	if max_value == -1:
		max_value = value
	_update_value()

func _update_value() -> void:
	$Label.text = str(round(value)) + " / " + str(round(max_value))
	$Progress.rect_size.x = 48 + ((rect_size.x - 48) * value) / max_value
