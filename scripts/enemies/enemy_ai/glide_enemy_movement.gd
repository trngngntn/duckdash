extends EnemyMovementAI
class_name GlideEnemyMovementAI

const UPDATE_INTERVAL = 0.2

var next_point: int
var last_target: Vector2
var dir: Vector2


func _get_custom_rpc_methods() -> Array:
	return [
		"set_dir",
	]


func _init(_enemy).(_enemy):
	pass


func move_to_target() -> void:
	last_target = enemy.target.position
	next_point = 1
	update_dir()


func move() -> void:
	# update_dir()
	enemy.apply_impulse(Vector2(0,0), (enemy.target.position - enemy.position) * 0.00005 * enemy.mv_speed)

# func integrate_forces(state) -> void:
# 	update_dir()
# 	state.linear_velocity = dir

func update_dir() -> void:
	dir = (enemy.target.position - enemy.position).normalized() * enemy.mv_speed
	# if next_point < path.size():
	# 	NakamaMatch.custom_rpc_sync(
	# 		self, "set_dir", []
	# 	)

