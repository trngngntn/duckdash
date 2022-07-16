extends Node2D

signal active(data)

var snap_step: int = -1
var snap_angle: float


func _ready():
	set_process(false)
	set_snap_step(1)


func _process(_delta) -> void:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var dir: Vector2 = (mouse - global_position).normalized()

	if snap_step > -1:
		var inac = dir.angle() / snap_angle
		dir = Vector2(1, 0).rotated(snap_angle * int(round(inac)))

	$Handle.position = dir * 10
	emit_signal("active", dir)


func _on_Area2D_mouse_exited() -> void:
	$Handle.position = Vector2(0, 0)
	set_process(false)


func _on_Area2D_mouse_entered() -> void:
	set_process(true)


func set_snap_step(step: int) -> void:
	snap_step = 4 + (step * 4)
	snap_angle = (2 * PI) / snap_step
