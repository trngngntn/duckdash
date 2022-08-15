class_name Item
extends RigidBody2D

signal picked_up

func _ready():
	mode = MODE_CHARACTER
	$AnimatedSprite.play()
	linear_damp = 8
	var rand_vec = Vector2(2 * randf() - 1, 2 * randf() - 1)
	apply_central_impulse(rand_vec.normalized() * 400)

func pick_up(node: Node):
	$CollisionShape2D.disabled = true
	var tween = create_tween()
	tween.connect("finished", self, "_on_finish")
	var dir = (node.position - position)
	var end_pos = position + dir - dir.normalized() * 20
	tween.tween_property(self, "position", end_pos, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _on_finish():
	emit_signal("picked_up")
	queue_free()
