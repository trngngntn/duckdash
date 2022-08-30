extends Area2D
class_name Skill

const base_speed: float = 400.0
const base_atk: float = 25.0
const base_decay: float = 0.25

var mul_atk_speed: float = 1
var mul_speed: float = 1
var mul_decay: float = 1
var mul_atk: float = 1

var tween: Tween
var decay_timer: Timer
var direction: Vector2

var peer_id: int


func _ready():
	if not MatchManager.is_network_server():
		$CollisionPolygon2D.disabled = true


func _atk_dir_trigger(player: Node, _direction: Vector2, _info: AtkInfo):
	var max_dir = StatManager.players_stat[peer_id].atk_dir
	for i in range(1, max_dir):
		var dir = (2.0 * i * PI) / max_dir + _direction.angle()
		_re_trigger(player, Vector2(1, 0).rotated(dir), _info)


func _proj_num_trigger(player: Node, _direction: Vector2, _info: AtkInfo):		
	var max_dir = StatManager.players_stat[peer_id].proj_num
	for i in range(0, max_dir):
		var dir = (2.0 * i * PI) / max_dir + _direction.angle()
		_re_trigger(player, Vector2(1, 0).rotated(dir), _info)


func _re_trigger(player: Node, dir: Vector2, info: AtkInfo) -> void:
	var new = duplicate(Node.DUPLICATE_USE_INSTANCING)
	new.trigger(player, dir, info, true)


func trigger(player: Node, dir: Vector2, info: AtkInfo, re_trigger: bool = false) -> void:
	if not re_trigger:
		_atk_dir_trigger(player, dir, info)


func gen_atk_info() -> AtkInfo:
	var crit_dict = Randomizer.get_crit_tier(StatManager.players_stat[peer_id].crit_chance, StatManager.players_stat[peer_id].crit_mul)
	return AtkInfo.new().create(peer_id, -1, StatManager.current_stat.atk_damage, [], crit_dict)


func _on_Area2D_area_entered(area: Area2D):
	if area.name == "EnemyHitboxArea":
		MatchManager.custom_rpc_sync(area.get_parent(), "hurt", [gen_atk_info().to_dict()])


func _on_AnimatedSprite_animation_finished():
	pass
