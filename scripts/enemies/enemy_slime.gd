extends Enemy


func init(nav: Navigation2D, _target: Node2D):
	mv_speed = 200
	target = _target
	movement_ai = LandEnemyMovementAI.new(self, nav)
	return self


func _ready():
	$AnimatedSprite.play("move")
