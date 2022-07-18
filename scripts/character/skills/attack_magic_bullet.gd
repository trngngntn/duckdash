extends Area2D

var speed: float = 1000
var decay: float = .3
var direction: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DecayTimer.wait_time = decay


func trigger(_direction: Vector2) -> void:
	direction = _direction.normalized()
	$AnimatedSprite.rotation = direction.angle() + PI / 2
	$AnimatedSprite.play("move")
	$DecayTimer.start()


func _physics_process(delta) -> void:
	position += direction * delta * speed


func _on_DecayTimer_timeout() -> void:
	speed /= 2.5
	$AnimatedSprite.play("disappear")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "disappear":
		queue_free()
