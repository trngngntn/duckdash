extends Node2D
class_name Joystick

var touch_range = 200

var snap_step: int = -1
var snap_angle: float

var output: Vector2
var _touch_index: int = -1

signal active(data)


func _ready():
	if not OS.has_touchscreen_ui_hint():
		hide()
	modulate.a = 0.25


func _reset() -> void:
	_touch_index = -1
	$Handle.position = Vector2(0, 0)
	emit_signal("active", Vector2(0, 0))
	modulate.a = 0.25


func _update(event_position: Vector2) -> void:
	output = (event_position - global_position).normalized()

	if snap_step > -1:
		var inac = output.angle() / snap_angle
		output = Vector2(1, 0).rotated(snap_angle * int(round(inac)))

	$Handle.position = output * 15
	emit_signal("active", output)

	modulate.a = 1
	get_tree().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		print("TOUCH")
		if event.is_pressed():
			if _touch_index == -1 && _is_in_range(event.position):
				_touch_index = event.index
				_update(event.position)
		elif event.index == _touch_index:
			_reset()
			get_tree().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update(event.position)


func _is_in_range(point: Vector2) -> bool:
	return point.distance_to(global_position) < touch_range


func set_snap_step(step: int) -> void:
	if step < -1:
		return
	snap_step = 4 + (step * 4)
	snap_angle = (2 * PI) / snap_step
