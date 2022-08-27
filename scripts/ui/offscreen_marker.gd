extends Node2D

onready var sprite = $Sprite

func _process(delta):
	var canvas = get_canvas_transform()
	var top_left = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	
	set_marker_position(Rect2(top_left, size))

func set_marker_position(bounds: Rect2):
	sprite.global_position.x = clamp(global_position.x, bounds.position.x, bounds.end.x)
	sprite.global_position.y = clamp(global_position.y, bounds.position.y, bounds.end.y)

func _on_VisibilityNotifier2D_screen_entered():
	hide()

func _on_VisibilityNotifier2D_screen_exited():
	show()
