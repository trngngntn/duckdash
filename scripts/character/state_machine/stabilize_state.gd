extends DuckState

var stab_mat: ShaderMaterial = preload("res://resources/material/stabilize_material.tres")
var norm_mat: ShaderMaterial = preload("res://resources/material/glitch_material.tres")
var noise_tex = preload("res://assets/sprites/noise/noise.png")

var material: ShaderMaterial = stab_mat.duplicate()


func _ready() -> void:
	pass


func init():
	pass


func enter(_dat := {}) -> void:
	player.attackable = false

	player.sprite.play("idle_left")

	material.set_shader_param("noise_tex", noise_tex)
	player.sprite.material = material

	var tween = get_tree().create_tween()
	tween.connect("finished", self, "_finish")
	tween.tween_method(self, "_stabilizing", player.stat.kinetic, 0.0, 3)

	get_tree().create_tween().tween_method(
		self, "_set_shader_param", 1.0, 0.0, 3, ["hologram_value"]
	)


func _set_shader_param(value, name):
	material.set_shader_param(name, value)


func _stabilizing(kin) -> void:
	StatManager.update_stat(get_network_master(), "kinetic", kin - player.stat.kinetic)


func _finish():
	state_machine.change_state("Idle")


func exit() -> void:
	player.attackable = true
	player.sprite.material = norm_mat.duplicate()
