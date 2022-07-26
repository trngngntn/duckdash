extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _ready():
	pass


func trigger(player: Node, _direction: Vector2) -> void:
	rotation = _direction.angle() + PI / 2
	player.add_child(self)
	$AnimatedSprite.play("move")
	$Tween.interpolate_property(
		$CollisionPolygon2D,
		"position:y",
		0,
		-4,
		0.05	
	)
	$Tween.start()
	pass


func _on_AnimatedSprite_animation_finished():
	queue_free()
