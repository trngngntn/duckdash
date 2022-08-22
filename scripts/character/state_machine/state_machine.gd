extends Node
class_name StateMachine

# onready var is_remote: bool

signal transitioned(state_name)

export var initial_state := NodePath()

onready var state: State = get_node(initial_state)


func _get_custom_rpc_methods() -> Array:
	return ["_remote_change_state"]


func _ready() -> void:
	yield(owner, "ready")
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		# print(child)
		child.state_machine = self


func start() -> void:
	# is_remote = MatchManager.self_peer_id != self.get_network_master()
	for child in get_children():
		child.init()
	# print("INIT_STATE: " + str(state))
	state.enter({})


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func change_state(target_state_name: String, dat := {}) -> void:
	if has_node(target_state_name):
		MatchManager.custom_rpc_sync(self, "_remote_change_state", [target_state_name, dat])


func _remote_change_state(target_state_name: String, dat := {}) -> void:
	if state.valid_change.has(target_state_name):
		# if not MatchManager.is_network_master_for_node(self):
		# 	print(
		# 		(
		# 			"REMOTE_STATE_CHANGE:"
		# 			+ state.name
		# 			+ " to "
		# 			+ target_state_name
		# 			+ " of "
		# 			+ str(MatchManager.is_network_master_for_node(self))
		# 		)
		# 	)

		state.exit()
		state = get_node(target_state_name)
		state.enter(dat)
		emit_signal("transitioned", state.name)
