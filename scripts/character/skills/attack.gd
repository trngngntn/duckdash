extends Area2D
class_name Attack

const base_speed: float = 400.0
const base_atk: float = 25.0
const base_decay: float = 0.25

var mul_speed: float = 1
var mul_decay: float = 1
var mul_atk: float = 1

var tween: Tween
var decay_timer: Timer
var direction: Vector2


func _ready():
	if not MatchManager.is_network_server():
		$CollisionPolygon2D.disabled = true


func trigger(_player: Node, _direction: Vector2) -> void:
	pass


func _on_Area2D_area_entered(area: Area2D):
	var node = area.get_parent()
	if node is Enemy:
		MatchManager.custom_rpc_sync(node, "hurt")


func _on_AnimatedSprite_animation_finished():
	pass
