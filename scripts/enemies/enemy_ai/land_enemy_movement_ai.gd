extends EnemyMovementAI
class_name LandEnemyMovementAI

const UPDATE_INTERVAL = 0.2

var nav: Navigation2D
var next_point: int
var path = []
var last_target: Vector2
var dir: Vector2

func _init(_enemy, _nav: Navigation2D).(_enemy):
	_nav.timer.connect("timeout", self, "on_timer_timeout")
	nav = _nav


func move_to_target() -> void:
	last_target = enemy.target.position
	path = nav.get_cached_simple_path(enemy.position, enemy.target.position)
	next_point = 1
	update_dir()

func move() -> void:
	# enemy.linear_velocity = (path[next_point] - enemy.position).normalized() * enemy.mv_speed
	# enemy.add_central_force(dir - enemy.linear_velocity)
	enemy.move_and_slide(dir, Vector2(0,0), false, 1, 0.785398, true)

# func integrate_forces(state) -> void:
# 	# state.linear_velocity = dir
# 	pass

func update_dir() -> void:
	dir = (path[next_point] - enemy.position).normalized() * enemy.mv_speed

func on_timer_timeout() -> void:
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

	# if not next_destination || enemy.position.distance_to(next_destination) < 5:
	# next_destination = nav.get_closest_point(enemy.target.position)
	# enemy.linear_velocity = (next_destination - enemy.position).normalized() * enemy.mv_speed
