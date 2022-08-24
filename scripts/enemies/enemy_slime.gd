extends Enemy

const TYPE = "SLIME"


func init(_spawner, _target: Duck, _name: String, _position: Vector2) -> Enemy:
	spawner = _spawner
	target = _target
	name = _name
	position = _position
	if MatchManager.current_match:
		_set_movement_ai(
			LandEnemyMovementAI.new(self, MatchManager.current_match.in_game_node.map.nav)
		)
	return self

func _ready():
	$AnimatedSprite.play("move")
