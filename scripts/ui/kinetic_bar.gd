extends NinePatchRect

var good = preload("res://assets/sprites/static/ui/ui_kinetic_bar_fg.png")
var norm = preload("res://assets/sprites/static/ui/ui_kinetic_bar_norm.png")
var bad = preload("res://assets/sprites/static/ui/ui_kinetic_bar_bad.png")

onready var stat: StatManager.StatValues

# func _ready():
# 	tween.start()


func _process(_delta):
	if not stat:
		stat = StatManager.current_stat
		return
	var value = stat.kinetic / stat.kin_thres
	value = clamp(value, -1, 1)
	update_value(value)


func update_value(value: float):
	var delta: float = stat.kin_thres - abs(stat.kinetic)
	if delta > 2 * stat.dash_kin:
		$Progress.texture = good
	elif delta > stat.dash_kin:
		$Progress.texture = norm
	else:
		$Progress.texture = bad

	if value <= 0:
		create_tween().tween_property(
			$Progress, "margin_left", -24 + ((rect_size.x - 48) / 2) * value, 0.1
		)
		# $Progress.margin_left = -24 + ((rect_size.x - 48) / 2) * value
		create_tween().tween_property($Progress, "margin_right", 24.0, 0.1)
	if value >= 0:
		create_tween().tween_property(
			$Progress, "margin_right", 24 + ((rect_size.x - 48) / 2) * value, 0.1
		)
		# $Progress.margin_right = 24 + ((rect_size.x - 48) / 2) * value
		create_tween().tween_property($Progress, "margin_left", -24.0, 0.1)
	create_tween().tween_property(
		$Indicator, "rect_position:x", (rect_size.x - 48) * ((value + 1) / 2), 0.1
	)
	# $Indicator.rect_position.x = (rect_size.x - 48) * ((value + 1) / 2)
