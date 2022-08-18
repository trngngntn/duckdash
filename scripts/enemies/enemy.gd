extends RigidBody2D
class_name Enemy

const ITEM_COIN = {"id": "COIN", "res": preload("res://scenes/items/auto_pickup/coin.tscn")}
const ITEM_SOUL = {"id": "SOUL", "res": preload("res://scenes/items/auto_pickup/soul.tscn")}
const ITEM_EMERALD = {
	"id": "EMERALD", "res": preload("res://scenes/items/auto_pickup/emerald.tscn")
}

const ITEM_LIST = {
	"COIN": ITEM_COIN,
	"SOUL": ITEM_SOUL,
	"EMERALD": ITEM_EMERALD,
}

const DIST_LIMIT_SQ = 1000000
var flash_mat: ShaderMaterial = preload("res://resources/material/hurt_shader_material.tres")

var attack_ai: EnemyAttackAI
var movement_ai: EnemyMovementAI

var target: Node2D
var upd_timer: Timer setget _set_upd_timer
var atk_timer: Timer
var flash_timer: Timer

var hp: float
var mv_speed: float
var atk_dmg: float = 5
var atk_speed: float = 1
var col_dmg: float = 5

var loot_tbl := {
	ITEM_COIN.id: [0.5, 0.1, 0.1],
	ITEM_SOUL.id: [0.1, 0.01],
}

var last_position: Vector2

var damageble: bool = true

onready var sprite: AnimatedSprite = get_node("AnimatedSprite")


func _get_custom_rpc_methods() -> Array:
	return ["frees", "kills", "_update", "hurt"]


func _init() -> void:
	# physics_material_override = PhysicsMaterial.new()
	# physics_material_override.friction = 0
	mode = RigidBody2D.MODE_CHARACTER
	# gravity_scale = 0
	pass


func _set_upd_timer(_upd_timer: Timer) -> void:
	if MatchManager.is_network_server():
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
		if MatchManager.is_network_server():
			movement_ai.move_to_target()

	if MatchManager.is_network_server():
		atk_timer = Timer.new()
		atk_timer.wait_time = 1 / atk_speed
		atk_timer.one_shot = false
		atk_timer.connect("timeout", self, "_on_atk_timer_timeout")
		add_child(atk_timer)
	else:
		$HitboxArea/CollisionPolygon2D.disabled = true


func _physics_process(_delta) -> void:
	if MatchManager.is_network_server():
		if not is_instance_valid(target) || target.is_queued_for_deletion():
			var players = get_tree().get_nodes_in_group("player")
			if players.size() == 0:
				queue_free()
				return

			var min_dist_player = players[0]
			var min_dist: float = min_dist_player.position.distance_squared_to(position)
			for player in get_tree().get_nodes_in_group("player"):
				if player != min_dist_player:
					var dist = player.position.distance_squared_to(position)
					if dist < min_dist:
						min_dist_player = player
						min_dist = dist
			target = min_dist_player
		if position.distance_squared_to(target.position) > DIST_LIMIT_SQ:
			MatchManager.custom_rpc_sync(self, "frees")
			return
	if movement_ai:
		movement_ai.move()


func _integrate_forces(state):
	if movement_ai && movement_ai.has_method("integrate_forces"):
		movement_ai.integrate_forces(state)


##SERVERONLY


func pre_kill():
	var info := []
	var map = MatchManager.current_match.in_game_node.map
	var rand_drop_item = Randomizer.rand_loot_table(loot_tbl)
	print("FINISH_RAND")
	for item in rand_drop_item:
		var rand_vec = Vector2(2 * randf() - 1, 2 * randf() - 1)
		map.drop_count += 1
		info.append({"dir": rand_vec, "type": item, "name": str(map.drop_count)})
	MatchManager.custom_rpc_sync(self, "kills", [position, info])


func kills(pos: Vector2, info_list: Array) -> void:
	for info in info_list:
		var item = get("ITEM_" + info["type"]).res.instance()
		item.add_to_group("drop_item")
		item.name = info["name"]
		item.position = pos
		item.fdir = info["dir"]
		get_parent().add_child(item)
	queue_free()


func frees() -> void:
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


func get_atk_info() -> AtkInfo:
	return AtkInfo.new().create(atk_dmg, [])


func _flash_timer_timeout() -> void:
	sprite.material.set_shader_param("enable", false)
	if hp <= 0:
		pre_kill()
		set_physics_process(false)


#### Update states functions
func _force_update() -> void:
	if position.distance_squared_to(last_position) > 4:
		MatchManager.custom_rpc(self, "_update", [position])
		last_position = position


func _update(pos: Vector2) -> void:
	# print("UPDATE_FORCED")
	position = pos


var colliding: Array = []


func _on_HitboxArea_area_entered(area: Area2D):
	var node = area.get_parent()
	if node.has_method("hurt"):
		colliding.append(node)
		node.hurt(get_atk_info())
		atk_timer.start()


func _on_HitboxArea_area_exited(area: Area2D):
	var node = area.get_parent()
	colliding.erase(node)
	if colliding.size() == 0:
		atk_timer.stop()


func _on_atk_timer_timeout():
	for node in colliding:
		node.hurt(get_atk_info())
