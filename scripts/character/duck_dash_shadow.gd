extends Sprite

class_name DashShadow


func _ready():
	$AlphaTween.interpolate_property(self, "modulate:a", .4, 0, .3, Tween.TRANS_EXPO, Tween.EASE_IN)
	$AlphaTween.interpolate_property(
		self, "scale", null, Vector2(0, 0), .3, Tween.TRANS_CUBIC, Tween.EASE_IN
	)
	$AlphaTween.start()


func _on_AlphaTween_tween_completed(_object: Object, _key: NodePath):
	queue_free()
