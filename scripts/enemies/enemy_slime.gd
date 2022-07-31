extends Enemy

var flash_timer: Timer


func init(nav: Navigation2D, _target: Node2D):
	mv_speed = 180
	hp = 100
	target = _target
	movement_ai = LandEnemyMovementAI.new(self, nav)
	flash_timer = Timer.new()
	flash_timer.wait_time = .2
	flash_timer.one_shot = true
	flash_timer.connect("timeout", self, "_flash_timer_timeout")
	add_child(flash_timer)
	return self


func _ready():
	$AnimatedSprite.play("move")


func hurt() -> void:
	sprite.material.set_shader_param("enable", true)
	hp -= 50
	if hp <= 0:
		$CollisionShape2D.disabled = true
		movement_ai = null
	flash_timer.start()


func _flash_timer_timeout() -> void:
	sprite.material.set_shader_param("enable", false)
	if hp <= 0:
		queue_free()
