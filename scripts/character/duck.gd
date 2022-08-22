extends KinematicBody2D
class_name Duck

var direction: Vector2
var dash_dest: Vector2
var tracking_cam: Camera2D setget set_tracking_cam

var is_attacking: bool = false
var attack_res

var move_joystick: Joystick = null
var atk_joystick: Joystick = null

var atk_direction: Vector2

var attackable: bool = true

var stat: StatManager.StatValues

onready var dash_area: Area2D = $DashHitArea2D
onready var sprite: AnimatedSprite = $AnimatedSprite

signal dead


func _get_custom_rpc_methods() -> Array:
	return ["_attack", "_hurt", "_force_update"]


func _ready() -> void:
	# if MatchManager.is_network_master_for_node(self):
	# 	StatManager.connect("stat_change", self, "_on_StatManager_stat_change")
	# if MatchManager.is_network_master_for_node(self):
	StatManager.connect("stat_change_peer_id", self, "_on_StatManager_stat_change_peer_id")


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


func finish_setup() -> void:
	stat = StatManager.players_stat[get_network_master()]
	var skill_caster = EquipmentManager.equipped["skill_caster"][0]
	attack_res = SkillCaster.SUB_TYPE[stat.skill]["res"]

	if MatchManager.is_network_master_for_node(self):
		if skill_caster.sub_type == "POWER_PUNCH" || skill_caster.sub_type == "TERROR_SLASH":
			$AttackTimer.wait_time = 1 / stat.atk_speed
		else:
			$AttackTimer.wait_time = 1 / stat.fire_rate
	else:
		$AttackTimer.stop()

	$StateMachine.start()


func _physics_process(delta):
	if $StateMachine.state.name != "Stabilize":
		var kin_delta = (
			6
			* pow(1 + stat.kin_rate, 3 * clamp(stat.kinetic / -stat.kin_thres, -1, 1))
			* delta
		)
		if MatchManager.is_network_master_for_node(self) || MatchManager.is_network_server():
			StatManager.update_stat(get_network_master(), "kinetic", -kin_delta)

	if not MatchManager.is_network_master_for_node(self):
		return

	if not atk_joystick:
		if Input.is_action_pressed("attack") && attackable:
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


func get_atk_info() -> AtkInfo:
	return AtkInfo.new().create(get_network_master(), -1, stat.atk_damage, [])


func attack() -> void:
	if not is_attacking:
		$AttackTimer.stop()
		return
	MatchManager.custom_rpc_sync(self, "_attack", [atk_direction, get_atk_info().to_dict()])


func hurt(info: AtkInfo) -> void:
	MatchManager.custom_rpc_sync(self, "_hurt", [info.to_dict()])


# CALLBACKS
func on_mouse_attack() -> void:
	attack()


func _on_AttackTimer_timeout():
	if attackable:
		attack()
	else:
		$AttackTimer.stop()


func _on_attack_joystick_active(data: Vector2) -> void:
	if data == Vector2(0, 0):
		is_attacking = false
		return
	atk_direction = data / 2
	if attackable && $AttackTimer.is_stopped():
		is_attacking = true
		attack()
		$AttackTimer.start()


func _on_StatManager_stat_change(stat_name: String, _change, new_value):
	# if stat_name == "kinetic":
	# 	if $StateMachine.state.name != "Stabilize" && abs(new_value) >= stat.kin_thres - 0.5:
	# 		$StateMachine.change_state("Stabilize")

	# 	var delta: float = stat.kin_thres - abs(stat.kinetic)
	# 	var kin2 = 2 * stat.dash_kin
	# 	if delta <= kin2:
	# 		var portion = delta / kin2
	# 		sprite.material.set_shader_param("amount", (1 - portion) * 20)
	# 		sprite.material.set_shader_param("size", portion * -9 + 1)
	# 	else:
	# 		sprite.material.set_shader_param("size", 0)
	pass


func _on_StatManager_stat_change_peer_id(peer_id: int, stat_name: String, _change, new_value):
	if stat_name == "kinetic" && peer_id == get_network_master():
		if (
			MatchManager.is_network_server()
			&& $StateMachine.state.name != "Stabilize"
			&& abs(new_value) >= stat.kin_thres - 0.5
		):
			$StateMachine.change_state("Stabilize")

		var delta: float = stat.kin_thres - abs(stat.kinetic)
		var kin2 = 2 * stat.dash_kin
		if delta <= kin2:
			var portion = delta / kin2
			sprite.material.set_shader_param("amount", (1 - portion) * 20)
			sprite.material.set_shader_param("size", portion * -9 + 1)
		else:
			sprite.material.set_shader_param("size", 0)


# RPC Functions
func _attack(_atk_dir: Vector2, info: Dictionary) -> void:
	var attack = attack_res.instance()
	attack.trigger(self, _atk_dir, AtkInfo.new().from_dict(info))


func _hurt(raw_info: Dictionary) -> void:
	var info = AtkInfo.new().from_dict(raw_info)
	StatManager.update_stat(get_network_master(), "hp", -info.dmg)

	if stat.hp < 1:
		emit_signal("dead")
		queue_free()
		return

	if sprite.material:
		sprite.material.set_shader_param("hurt", true)

	$FlashTimer.start()

func _force_update(_position: Vector2) -> void:
	position = _position



func _on_PickUpArea2D_body_entered(body: Node):
	if body is DropItem:
		# StatManager.calculate_stat_from_looting(body.modifier)
		MatchManager.custom_rpc_sync(body, "pick_up", [self.get_path(), get_network_master()])


func _on_FlashTimer_timeout():
	if sprite.material:
		sprite.material.set_shader_param("hurt", false)
