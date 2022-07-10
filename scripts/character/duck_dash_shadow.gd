extends Sprite

class_name DashShadow

func _ready():
	$AlphaTween.interpolate_property(self, "modulate:a", .35, 0, .3, Tween.TRANS_LINEAR)
	$AlphaTween.start()


func _on_AlphaTween_tween_completed(_object:Object, _key:NodePath):
	queue_free() 
