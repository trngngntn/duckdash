extends Enemy

const TYPE = "BEE"


func init(_spawner, _target: Duck, _name: String, _position: Vector2) -> Enemy:
	mul_mv_speed = 1.5
	hp_mul = 2
	atk_dmg = 1
	loot_tbl[ITEM_HEART.id] = [0.5, 0.1]
	loot_tbl[ITEM_SAPPHIRE.id] = [0.25]
	.init(_spawner, _target, _name, _position)
	_set_movement_ai(FlyEnemyMovementAI.new(self))
	return self


func _ready() -> void:
	last_position = position


func _process(_delta) -> void:
	if (position - last_position).x > 0:
		$AnimatedSprite.play("move_right")
		$EnemyHitboxArea/CollisionPolygon2D.scale.x = 1
	else:
		$AnimatedSprite.play("move_left")
		$EnemyHitboxArea/CollisionPolygon2D.scale.x = -1
