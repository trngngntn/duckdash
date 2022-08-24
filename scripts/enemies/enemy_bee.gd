extends Enemy

const TYPE = "BEE"


func init():
	mul_mv_speed = 1.5
	hp = 2
	atk_dmg = 1
	self.movement_ai = FlyEnemyMovementAI.new(self)


func _ready() -> void:
	last_position = position


func _process(_delta) -> void:
	if (position - last_position).x > 0:
		$AnimatedSprite.play("move_right")
		$EnemyHitboxArea/CollisionPolygon2D.scale.x = 1
	else:
		$AnimatedSprite.play("move_left")
		$EnemyHitboxArea/CollisionPolygon2D.scale.x = -1
