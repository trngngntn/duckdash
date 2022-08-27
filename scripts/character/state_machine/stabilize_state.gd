extends DuckState

var stab_mat: ShaderMaterial = preload("res://resources/material/stabilize_material.tres")
var noise_tex = preload("res://assets/sprites/noise/noise.png")

var material: ShaderMaterial = stab_mat.duplicate()

var base = 1
var stat: StatManager.StatValues


func _ready() -> void:
	pass


func init():
	valid_change = [STATE_IDLE]
	stat = StatManager.players_stat[get_network_master()]


func enter(_dat := {}) -> void:
	player.attackable = false

	player.sprite.play("idle_left")

	material.set_shader_param("noise_tex", noise_tex)
	player.sprite.material = material
	var tween = get_tree().create_tween()
	tween.tween_method(self, "_set_shader_param", 1.0, 0.0, 3, ["hologram_value"])

	if stat.kinetic > 0:
		base = -1
	else:
		base = 1


func _set_shader_param(value, name):
	material.set_shader_param(name, value)


func physics_update(delta: float) -> void:
	var change = base * delta * 0.333 * stat.kin_thres
	StatManager.update_stat(get_network_master(), "kinetic", change)
	if MatchManager.is_network_server() && ((base < 0) == (stat.kinetic < 0)):
		state_machine.change_state("Idle", {"pos": player.position})

# func _on_stat_change_peer_id()

func exit() -> void:
	player.attackable = true
