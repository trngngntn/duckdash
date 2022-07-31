extends KinematicBody2D
class_name Enemy

const DIST_LIMIT_SQ = 1000 * 1000

var attack_ai: EnemyAttackAI
var movement_ai: EnemyMovementAI

var target: Node2D

var hp: float
var mv_speed: float

onready var sprite: AnimatedSprite = get_node("AnimatedSprite")


func _init() -> void:
	# physics_material_override = PhysicsMaterial.new()
	# physics_material_override.friction = 0
	# mode = RigidBody2D.MODE_CHARACTER
	# gravity_scale = 0
	pass


func _ready() -> void:
	if movement_ai:
		add_child(movement_ai)
		movement_ai.move_to_target()


func _physics_process(_delta):
	if position.distance_squared_to(target.position) > DIST_LIMIT_SQ:
		queue_free()
		return
	if movement_ai:
		movement_ai.move()

# func _integrate_forces(state):
#     if movement_ai:
#         movement_ai.integrate_forces(state)
