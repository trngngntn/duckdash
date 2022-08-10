extends Enemy


func init(nav: Navigation2D, _target: Node2D, _upd_timer: Timer) -> Enemy:
	mv_speed = 250
	hp = 40
	target = _target
	self.movement_ai = FlyEnemyMovementAI.new(self)

	self.upd_timer = _upd_timer
	return self


func _ready() -> void:
	last_position = position


func _process(_delta) -> void:
	if (position - last_position).x > 0:
		$AnimatedSprite.play("move_right")
		$HitboxArea/CollisionPolygon2D.scale.x = 1
	else:
		$AnimatedSprite.play("move_left")
		$HitboxArea/CollisionPolygon2D.scale.x = -1
