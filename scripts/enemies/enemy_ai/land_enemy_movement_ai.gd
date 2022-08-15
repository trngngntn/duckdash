extends EnemyMovementAI
class_name LandEnemyMovementAI

const UPDATE_INTERVAL = 0.2

var nav: Navigation2D
var next_point: int
var path = []
var last_target: Vector2
var dir: Vector2


func _get_custom_rpc_methods() -> Array:
	return [
		"set_dir",
	]


func _init(_enemy, _nav: Navigation2D).(_enemy):
	if MatchManager.is_network_server():
		_nav.timer.connect("timeout", self, "on_NavTimer_timeout")
		nav = _nav


func move_to_target() -> void:
	last_target = enemy.target.position
	path = nav.get_cached_simple_path(enemy.position, enemy.target.position)
	next_point = 1
	update_dir()


func move() -> void:
	# enemy.linear_velocity = dir
	# # enemy.add_central_force(dir - enemy.linear_velocity)
	pass

func integrate_forces(state) -> void:
	state.linear_velocity = dir


func update_dir() -> void:
	if next_point < path.size():
		MatchManager.custom_rpc_sync(
			self, "set_dir", [(path[next_point] - enemy.position).normalized() * enemy.mv_speed]
		)


func on_NavTimer_timeout() -> void:
	if enemy.target.position.distance_squared_to(last_target) > 40000:
		last_target = enemy.target.position
		path = nav.force_update_path(path, enemy.position, enemy.target.position)
		next_point = 1
		update_dir()
	elif next_point < path.size() - 1:
		if (enemy.position - path[next_point]).dot(enemy.position - path[next_point - 1]) > 0:
			next_point = next_point + 1
			update_dir()
		else:
			return
	else:
		path = nav.force_update_path(path, enemy.position, enemy.target.position)
		next_point = 1


##REMOTE FUNCTIONS
func set_dir(_dir: Vector2) -> void:
	dir = _dir
