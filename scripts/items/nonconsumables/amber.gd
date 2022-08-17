extends NonConsumable

# TODO: change stat type
var incr_stat := IncrementModifier.new("max_hp", 1)

func _init() -> void:
	modifier = incr_stat
