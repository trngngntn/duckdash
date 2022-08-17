extends RigidBody2D
class_name NonConsumable

var fdir: Vector2 = Vector2(0, 0)
var synced: bool = false
var sync_pos: Vector2
var modifier: IncrementModifier

signal picked_up

func _get_custom_rpc_methods() -> Array:
	return ["sync", "pick_up"]

func _ready():
	mode = MODE_CHARACTER
	$AnimatedSprite.play()
	linear_damp = 8
	apply_central_impulse(fdir * 400)

func _intergrate_forces(_state):
	if MatchManager.is_network_server() && not synced && linear_velocity.length_squared() < 4:
		MatchManager.custom_rpc(self, "sync", [position])
		print("[LOG][SYNC] " + str(position))

	if not MatchManager.is_network_server() && synced:
		position = sync_pos

func pick_up(node_path: NodePath):
	var node = get_node(node_path)
	print("[LOG][MUST_SYNC] " + str(position))
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.connect("finished", self, "_on_finish")
	var dir = node.position - position
	var end_pos = position + dir - dir.normalized() * 20
	tween.tween_property(self, "position", end_pos, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_IN
	)

func _on_finish():
	emit_signal("picked_up")
	# StatManager.calculate_stat_from_noncomsumable(modifier)
	queue_free()

func sync(pos: Vector2):
	$CollisionShape2D.set_deferred("disabled", true)
	synced = true
	sync_pos = pos
