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
	if not has_node(target_state_name):
		return
	# print("CHANGE_STATE: " + target_state_name + " from " + state.name)
	state.exit()
	state = get_node(target_state_name)
	state.enter(dat)
	MatchManager.custom_rpc(self, "_remote_change_state", [target_state_name, dat])
	emit_signal("transitioned", state.name)


func _remote_change_state(target_state_name: String, dat := {}) -> void:
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(dat)
	emit_signal("transitioned", state.name)
