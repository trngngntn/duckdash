extends NinePatchRect

var value: float = 0 setget _set_value
var max_value: float = -1 setget _set_max_value


func _ready():
	StatManager.connect("stat_change", self, "_on_stat_change")
	StatManager.connect("stat_calculated", self, "_on_stat_ready")


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
	var tween = create_tween()
	tween.tween_property(
		$Progress, "rect_size:x", 48 + ((rect_size.x - 48) * value) / max_value, 0.1
	)
	# $Progress.rect_size.x = 48 + ((rect_size.x - 48) * value) / max_value


func _on_stat_ready() -> void:
	_set_max_value(StatManager.current_stat.max_hp)
	_set_value(StatManager.current_stat.hp)


func _on_stat_change(stat_name: String, _change, new_value) -> void:
	match stat_name:
		"hp":
			_set_value(new_value)
		"max_hp":
			_set_max_value(new_value)
