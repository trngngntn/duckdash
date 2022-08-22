extends Enemy


func init(nav: Navigation2D, _target: Node2D):
	target = _target
	self.movement_ai = LandEnemyMovementAI.new(self, nav)

	return self


func _ready():
	$AnimatedSprite.play("move")
