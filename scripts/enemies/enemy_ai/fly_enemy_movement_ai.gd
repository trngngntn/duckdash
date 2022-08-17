extends EnemyMovementAI
class_name FlyEnemyMovementAI

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
	update_dir()
	enemy.linear_velocity = dir


func update_dir() -> void:
	dir = (enemy.target.position - enemy.position).normalized() * enemy.mv_speed
	# if next_point < path.size():
	# 	NakamaMatch.custom_rpc_sync(
	# 		self, "set_dir", []
	# 	)

