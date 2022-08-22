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


func trigger(_player: Node, _direction: Vector2, _info: AtkInfo) -> void:
	pass


func gen_atk_info() -> AtkInfo:
	return AtkInfo.new().create(peer_id, -1, StatManager.current_stat.atk_damage, [])


func _on_Area2D_area_entered(area: Area2D):
	if area.name == "EnemyHitboxArea":
		MatchManager.custom_rpc_sync(area.get_parent(), "hurt", [gen_atk_info().to_dict()])


func _on_AnimatedSprite_animation_finished():
	pass
