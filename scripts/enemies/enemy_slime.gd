extends Enemy


func init(nav: Navigation2D, _target: Node2D, _upd_timer: Timer):
	hp = 100
	target = _target
	self.movement_ai = LandEnemyMovementAI.new(self, nav)
	
	self.upd_timer = _upd_timer
	return self


func _ready():
	$AnimatedSprite.play("move")
