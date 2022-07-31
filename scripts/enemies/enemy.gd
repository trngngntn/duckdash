extends KinematicBody2D
class_name Enemy

var attack_ai: EnemyAttackAI
var movement_ai: EnemyMovementAI
var target: Node2D
var mv_speed: float

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
    if movement_ai:
        movement_ai.move()

func _integrate_forces(state):
    if movement_ai:
        movement_ai.integrate_forces(state)