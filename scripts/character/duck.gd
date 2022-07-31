extends KinematicBody2D
class_name Duck

var direction: Vector2
var speed: float = 220
var dash_speed: float = 1200
var dash_range: float = 250
var is_dashing: bool = false
var dash_dest: Vector2
var tracking_cam: Camera2D setget set_tracking_cam

var is_attacking: bool = false
var attack_res = preload("res://scenes/character/skills/attack_terror_slash.tscn")

var move_joystick: Joystick = null
var atk_joystick: Joystick = null

var atk_direction: Vector2

onready var dash_area: Area2D = $DashHitArea2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AttackTimer.wait_time = .5


func set_tracking_cam(cam: Camera2D) -> void:
	tracking_cam = cam


func set_player_name(name: String) -> void:
	$ColorRect/Label.text = name


func map_move_joystick(_joystick: Joystick) -> void:
	if OS.get_name() == "Android":
		move_joystick = _joystick


func map_attack_joystick(_joystick: Joystick) -> void:
	if OS.get_name() == "Android":
		atk_joystick = _joystick
		atk_joystick.connect("active", self, "_on_attack_joystick_active")
		set_physics_process(false)


func _process(_delta):
	if not atk_joystick:
		if Input.is_action_pressed("attack"):
			atk_direction = (
				get_viewport().get_mouse_position()
				- get_viewport().size / 2
				- (position - tracking_cam.position)
			)
			atk_direction.x /= 2
			if $AttackTimer.is_stopped():
				is_attacking = true
				on_mouse_attack()
				$AttackTimer.start()
		else:
			is_attacking = false
	# else:
	# 	if atk_joystick.output == Vector2(0,0):
	# 		is_attacking = false
	# 		return
	# 	atk_direction = atk_joystick.output / 2
	# 	if $AttackTimer.is_stopped():
	# 		is_attacking = true
	# 		attack()
	# 		$AttackTimer.start()


func finish_setup() -> void:
	$StateMachine.start()


func attack() -> void:
	if not is_attacking:
		$AttackTimer.stop()
		return
	var attack = attack_res.instance()
	attack.trigger(self, atk_direction)
	pass


func on_mouse_attack() -> void:
	# atk_direction = (((get_viewport().get_mouse_position() + tracking_cam.position) - position) / 2)
	attack()


func _on_AttackTimer_timeout():
	attack()


func _on_attack_joystick_active(data: Vector2) -> void:
	if data == Vector2(0, 0):
		is_attacking = false
		return
	atk_direction = data / 2
	if $AttackTimer.is_stopped():
		is_attacking = true
		attack()
		$AttackTimer.start()
