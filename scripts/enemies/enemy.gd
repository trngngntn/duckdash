extends RigidBody2D
class_name Enemy

const DIST_LIMIT_SQ = 1000000
var flash_mat: ShaderMaterial = preload("res://resources/material/hurt_shader_material.tres")

var attack_ai: EnemyAttackAI
var movement_ai: EnemyMovementAI

var target: Node2D
var upd_timer: Timer setget _set_upd_timer
var flash_timer: Timer

var hp: float
var mv_speed: float
var atk_dmg: float
var atk_speed: float = 1
var col_dmg: float = 10

var last_position: Vector2


var damageble: bool = true

onready var sprite: AnimatedSprite = get_node("AnimatedSprite")


func _get_custom_rpc_methods() -> Array:
	return ["kills", "_update", "hurt"]


func _init() -> void:
	# physics_material_override = PhysicsMaterial.new()
	# physics_material_override.friction = 0
	mode = RigidBody2D.MODE_CHARACTER
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

	flash_timer = Timer.new()
	flash_timer.wait_time = .2
	flash_timer.one_shot = true
	flash_timer.connect("timeout", self, "_flash_timer_timeout")
	add_child(flash_timer)

	$CollisionAtkTimer.wait_time = 0.5
	$DirectAtkTimer.wait_time = 1 / atk_speed

	if movement_ai:
		add_child(movement_ai)
		if NakamaMatch.is_network_server():
			movement_ai.move_to_target()


func _physics_process(_delta) -> void:
	if NakamaMatch.is_network_server():
		if position.distance_squared_to(target.position) > DIST_LIMIT_SQ:
			NakamaMatch.custom_rpc_sync(self, "kills")
			return
	if movement_ai:
		movement_ai.move()


func _integrate_forces(state):
	if movement_ai && movement_ai.has_method("integrate_forces"):
		movement_ai.integrate_forces(state)


func kills() -> void:
	queue_free()


func hurt() -> void:
	sprite.material = flash_mat.duplicate()
	# sprite.material.resource_local_to_scene = true
	sprite.material.set_shader_param("enable", true)
	hp -= 50
	if hp <= 0:
		damageble = false
		movement_ai = null
	flash_timer.start()


func _flash_timer_timeout() -> void:
	sprite.material.set_shader_param("enable", false)
	if hp <= 0:
		kills()
		set_physics_process(false)

#### Update states functions
func _force_update() -> void:
	if position.distance_squared_to(last_position) > 4:
		NakamaMatch.custom_rpc(self, "_update", [position])
		last_position = position


func _update(pos: Vector2) -> void:
	# print("UPDATE_FORCED")
	position = pos


func _on_HitboxArea_area_entered(area:Area2D):
	var node = area.get_parent()
	if node.has_method("hurt"):
		node.hurt()
