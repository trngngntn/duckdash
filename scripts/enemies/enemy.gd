extends RigidBody2D
class_name Enemy

const ITEM_COIN = {"id": "COIN", "res": preload("res://scenes/items/auto_pickup/coin.tscn")}
const ITEM_SOUL = {"id": "SOUL", "res": preload("res://scenes/items/auto_pickup/soul.tscn")}
const ITEM_HEART = {"id": "HEART", "res": preload("res://scenes/items/auto_pickup/heart.tscn")}
const ITEM_EMERALD = {
	"id": "EMERALD", "res": preload("res://scenes/items/auto_pickup/emerald.tscn")
}
const ITEM_SAPPHIRE = {
	"id": "SAPPHIRE", "res": preload("res://scenes/items/auto_pickup/sapphire.tscn")
}
const ITEM_RUBY = {
	"id": "RUBY", "res": preload("res://scenes/items/auto_pickup/ruby.tscn")
}
const DIST_LIMIT_SQ = 1000000
const FLASH_MAT: ShaderMaterial = preload("res://resources/material/hurt_shader_material.tres")

var attack_ai: EnemyAttackAI
var movement_ai: EnemyMovementAI

var target: Node2D

var spawner

var atk_timer: Timer
var flash_timer: Timer

var hp: float = 10
var hp_mul: float = 1
var mv_speed: float = 150
var mul_mv_speed: float = 1
var atk_dmg: float = 5
var atk_speed: float = 1
var col_dmg: float = 5

var loot_tbl := {
	ITEM_COIN.id: [0.4, 0.1, 0.05],
	ITEM_SOUL.id: [0.1, 0.01],
	ITEM_HEART.id: [0.10, 0.025],
	ITEM_SAPPHIRE.id: [0.025],
	ITEM_EMERALD.id: [0.075],
	ITEM_RUBY.id: [0.025],
}

var last_position: Vector2

var damageble: bool = true

onready var sprite: AnimatedSprite = $AnimatedSprite


func _get_custom_rpc_methods() -> Array:
	return ["frees", "kills", "_update", "hurt"]


func _init() -> void:
	mode = RigidBody2D.MODE_CHARACTER

func init(_spawner, _target, _name: String, _position: Vector2):
	spawner = _spawner
	target = _target
	name = _name
	position = _position


func _set_movement_ai(_ai: EnemyMovementAI) -> void:
	movement_ai = _ai
	add_child(movement_ai)
	# movement_ai.name ="MovementAI"


func _ready() -> void:
	last_position = position
	sprite.material = FLASH_MAT.duplicate()

	mv_speed *= mul_mv_speed
	hp *= hp_mul

	$CollisionAtkTimer.wait_time = 0.5
	$DirectAtkTimer.wait_time = 1 / atk_speed

	if MatchManager.is_network_server():
		Updater.connect("timeout_slow", self, "_force_update")
		atk_timer = Timer.new()
		atk_timer.wait_time = 1 / atk_speed
		atk_timer.one_shot = false
		atk_timer.connect("timeout", self, "_on_atk_timer_timeout")
		add_child(atk_timer)
		if movement_ai:
			movement_ai.move_to_target()
	else:
		$EnemyHitboxArea/CollisionPolygon2D.disabled = true


func _physics_process(_delta) -> void:
	if MatchManager.is_network_server():
		if not is_instance_valid(target) || target.is_queued_for_deletion():
			var players = get_tree().get_nodes_in_group("player")
			if players.size() == 0:
				# queue_free()
				spawner.free_enemy(self)
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
	for item in rand_drop_item:
		var rand_vec = Vector2(2 * randf() - 1, 2 * randf() - 1)
		map.drop_count += 1
		info.append({"dir": rand_vec, "type": item, "name": str(map.drop_count)})
	MatchManager.custom_rpc_sync(self, "kills", [position, info])


func kills(pos: Vector2, info_list: Array) -> void:
	for info in info_list:
		print("KILLL SER")
		var item = get("ITEM_" + info["type"]).res.instance()
		item.add_to_group("drop_item")
		item.name = info["name"]
		item.position = pos
		item.fdir = info["dir"]
		# get_parent().add_child(item)
		get_parent().call_deferred("add_child", item)
	# queue_free()
	spawner.free_enemy(self)


func frees() -> void:
	# queue_free()
	spawner.free_enemy(self)


func hurt(raw_info: Dictionary) -> void:
	var info: AtkInfo = AtkInfo.new().from_dict(raw_info)
	sprite.material.set_shader_param("hurt", true)
	hp -= info.dmg
	if hp <= 0:
		$EnemyHitboxArea/CollisionPolygon2D.set_deferred("disabled", true)
		damageble = false
		movement_ai = null
		if MatchManager.is_network_server():
			pre_kill()
		set_physics_process(false)
	else:
		$FlashTimer.start()


func get_atk_info(peer_id: int) -> AtkInfo:
	return AtkInfo.new().create(-1, peer_id, atk_dmg, [])


#### Update states functions
func _force_update() -> void:
	if position.distance_squared_to(target.position) > DIST_LIMIT_SQ:
		var players = get_tree().get_nodes_in_group("player")
		var valid: bool = false
		for player in players:
			if (
				is_instance_valid(player)
				&& not player.is_queued_for_deletion()
				&& player != target
				&& position.distance_squared_to(player.position) <= DIST_LIMIT_SQ
			):
				valid = true
				target = player
				break
		if not valid:
			MatchManager.custom_rpc_sync(self, "frees")
			return
	if position.distance_squared_to(last_position) > 4:
		MatchManager.custom_rpc(self, "_update", [position])
		last_position = position


func _update(pos: Vector2) -> void:
	# print("UPDATE_FORCED")
	position = pos


var colliding: Array = []


func _on_HitboxArea_area_entered(area: Area2D):
	if not area is Skill:
		var node = area.get_parent()
		if node.has_method("hurt"):
			colliding.append(node)
			node.hurt(get_atk_info(node.get_network_master()))
			atk_timer.start()


func _on_HitboxArea_area_exited(area: Area2D):
	var node = area.get_parent()
	colliding.erase(node)
	if colliding.size() == 0:
		atk_timer.stop()


func _on_atk_timer_timeout():
	for node in colliding:
		node.hurt(get_atk_info(node.get_network_master()))


func _on_FlashTimer_timeout():
	sprite.material.set_shader_param("hurt", false)


func _on_Node2D_tree_exiting():
	pass
