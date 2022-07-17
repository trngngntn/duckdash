extends Node
class_name State

var state_machine = null

# func _get_custom_rpc_methods() -> Array:
# 	return [
# 		"_remote_update",
# 		"_remote_physics_update"
# 	]

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func init() -> void:
	pass

func enter(_dat := {}) -> void:
	pass

func exit() -> void:
	pass