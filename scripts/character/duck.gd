extends KinematicBody2D
class_name Duck

var direction: Vector2
var dash_dest: Vector2
var tracking_cam: Camera2D setget set_tracking_cam

var is_attacking: bool = false
var attack_res = preload("res://scenes/character/skills/skill_attack_energy_blade.tscn")

var flash_mat: ShaderMaterial = preload("res://resources/material/hurt_shader_material.tres")

var move_joystick: Joystick = null
var atk_joystick: Joystick = null

var atk_direction: Vector2

var stat: StatManager.StatValues

onready var dash_area: Area2D = $DashHitArea2D

signal hp_max_changed(new_value)
signal hp_changed(new_value)

signal kinetic_threshold_changed(new_value)
signal kinetic_changed(new_value)

signal dead


func _get_custom_rpc_methods() -> Array:
	return ["_attack", "_hurt"]


func _ready() -> void:
	if MatchManager.is_network_master_for_node(self):
		$AttackTimer.wait_time = .5
	else:
		$AttackTimer.stop()


func set_tracking_cam(cam: Camera2D) -> void:
	tracking_cam = cam


func set_player_name(name: String) -> void:
	$ColorRect/Label.text = name


func map_move_joystick(_joystick: Joystick) -> void:
	if OS.has_touchscreen_ui_hint():
		move_joystick = _joystick


func map_attack_joystick(_joystick: Joystick) -> void:
	if OS.has_touchscreen_ui_hint():
		atk_joystick = _joystick
		atk_joystick.connect("active", self, "_on_attack_joystick_active")
		set_physics_process(false)


func finish_setup() -> void:
	print("NETWORK MASTER: " + str(MatchManager.get_network_master()))
	if MatchManager.is_network_server():
		stat = StatManager.players_stat[MatchManager.get_network_master()]
	elif MatchManager.is_network_master_for_node(self):
		stat = StatManager.current_stat
	$StateMachine.start()


func _physics_process(delta):
	if not MatchManager.is_network_master_for_node(self):
		return
	stat.kinetic -= delta*stat.kin_rate
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


func attack() -> void:
	if not is_attacking:
		$AttackTimer.stop()
		return
	MatchManager.custom_rpc_sync(self, "_attack", [atk_direction])


func hurt(info: AtkInfo) -> void:
	MatchManager.custom_rpc_sync(self, "_hurt", [info.to_dict()])


# CALLBACKS
func on_mouse_attack() -> void:
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


# RPC Functions
func _attack(_atk_dir: Vector2) -> void:
	var attack = attack_res.instance()
	attack.trigger(self, _atk_dir)
	pass


func _hurt(raw_info: Dictionary) -> void:
	var info = AtkInfo.new().from_dict(raw_info)
	stat.hp -= info.dmg
	emit_signal("hp_changed", stat.hp)

	if stat.hp < 1:
		emit_signal("dead")
		queue_free()
		return

	$AnimatedSprite.material = flash_mat.duplicate()
	$AnimatedSprite.material.set_shader_param("enable", true)

	$FlashTimer.start()

func _on_PickUpArea2D_body_entered(body: Node):
	if body is Item:
func _on_PickUpArea2D_body_entered(body:Node):
	if body is NonConsumable:
		StatManager.calculate_stat_from_looting(body.modifier)
		MatchManager.custom_rpc_sync(body, "pick_up", [self.get_path()])


func _on_FlashTimer_timeout():
	$AnimatedSprite.material = null
