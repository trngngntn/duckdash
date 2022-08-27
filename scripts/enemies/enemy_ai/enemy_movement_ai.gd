extends Node
class_name EnemyMovementAI

var enemy
var active: bool = true

func _init(_enemy):
	enemy = _enemy
	# name = "MovementAI"
	enemy.connect("tree_exited", self, "_on_tree_changed", [false])
	enemy.connect("tree_entered", self, "_on_tree_changed", [true])

func _on_tree_changed(state: bool):
	active = state

func move_to_target() -> void:
	pass

func move() -> void:
	pass