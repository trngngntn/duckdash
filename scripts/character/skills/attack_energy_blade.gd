extends Area2D

var speed: float = 500
var decay: float = .2
var direction: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DecayTimer.wait_time = decay


func trigger(player: Node, _direction: Vector2) -> void:
	player.get_parent().add_child(self)
	direction = _direction.normalized()
	position = player.position + (_direction.normalized() *Vector2(0.5 , 1) * 32)
	$AnimatedSprite.rotation = direction.angle() + PI / 2
	$AnimatedSprite.play("move")
	$DecayTimer.start()

func _physics_process(delta) -> void:
	position += direction * delta * speed


func _on_DecayTimer_timeout() -> void:
	speed /= 2
	$AnimatedSprite.play("disappear")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "disappear":
		queue_free()
