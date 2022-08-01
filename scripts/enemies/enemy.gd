extends KinematicBody2D
class_name Enemy

const DIST_LIMIT_SQ = 1000 * 1000

var attack_ai: EnemyAttackAI
var movement_ai: EnemyMovementAI

var target: Node2D
var upd_timer: Timer setget _set_upd_timer

var hp: float
var mv_speed: float

var last_position: Vector2
var damageble: bool = true

onready var sprite: AnimatedSprite = get_node("AnimatedSprite")


func _get_custom_rpc_methods() -> Array:
	return ["kills", "_update"]


func _init() -> void:
	# physics_material_override = PhysicsMaterial.new()
	# physics_material_override.friction = 0
	# mode = RigidBody2D.MODE_CHARACTER
	# gravity_scale = 0
	pass


func _set_upd_timer(_upd_timer: Timer) -> void:
	if NakamaMatch.is_network_server():
		upd_timer = _upd_timer
		upd_timer.connect("timeout", self, "_force_update")


func _set_movement_ai(_ai: EnemyMovementAI) -> void:
	movement_ai = _ai


func _ready() -> void:
	last_position = position
	if movement_ai:
		add_child(movement_ai)
		if NakamaMatch.is_network_server():
			movement_ai.move_to_target()


func _physics_process(_delta) -> void:
	if NakamaMatch.is_network_server():
		if position.distance_squared_to(target.position) > DIST_LIMIT_SQ:
			NakamaMatch.custom_rpc_sync(self, "kills", [])
			return
	if movement_ai:
		movement_ai.move()


# func _integrate_forces(state):
#     if movement_ai:
#         movement_ai.integrate_forces(state)


func kills() -> void:
	queue_free()


func _force_update() -> void:
	# print("FORCE_UPDATE_CLIENT")
	# NakamaMatch.custom_rpc(self, "_update", [position])
	# print("FDIST: " + str(position.distance_squared_to(last_position) ))
	if position.distance_squared_to(last_position) > 4:
		NakamaMatch.custom_rpc(self, "_update", [position])
		last_position = position


func _update(pos: Vector2) -> void:
	# print("UPDATE_FORCED")
	position = pos
