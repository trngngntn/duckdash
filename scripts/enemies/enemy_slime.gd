extends Enemy

const TYPE = "SLIME"


func init(_spawner, _target: Duck, _name: String, _position: Vector2, _eid: int) -> Enemy:
	.init(_spawner, _target, _name, _position, _eid)
	if MatchManager.current_match:
		_set_movement_ai(
			LandEnemyMovementAI.new(self, MatchManager.current_match.in_game_node.map.nav)
		)
		# self.movement_ai = LandEnemyMovementAI.new(self, MatchManager.current_match.in_game_node.map.nav)
	return self

func _ready():
	$AnimatedSprite.play("move")
