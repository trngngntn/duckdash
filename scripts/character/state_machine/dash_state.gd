extends DuckState

var direction: Vector2
var dash_timer: Timer
var effect_timer: Timer
var tween: Tween

var last_speed: float
var speed: float
var _shadow = preload("res://scenes/character/duck_dash_shadow.tscn")

var _d


func _ready() -> void:
	effect_timer = Timer.new()
	effect_timer.wait_time = .01
	_d = effect_timer.connect("timeout", self, "_cloning")
	add_child(effect_timer)

	dash_timer = Timer.new()
	add_child(dash_timer)

	tween = Tween.new()
	_d = tween.connect("tween_completed", self, "_end_dash")
	add_child(tween)


func init():
	_d = player.dash_area.connect("body_entered", self, "_on_collision")


func enter(dat := {}) -> void:
	direction = dat.direction.normalized()
	last_speed = StatManager.players_stat[get_network_master()].dash_speed

	if dat.direction.x > 0:
		player.sprite.play("dash_right")
	else:
		player.sprite.play("dash_left")

	var duration: float = (
		StatManager.players_stat[get_network_master()].dash_range
		/ StatManager.players_stat[get_network_master()].dash_speed
	)

	dash_timer.wait_time = duration
	dash_timer.one_shot = true
	dash_timer.start()
	effect_timer.start()

	_d = tween.interpolate_property(
		self,
		"speed",
		(StatManager.current_stat.dash_speed + StatManager.current_stat.mv_speed) / 2,
		StatManager.current_stat.dash_speed,
		duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)

	StatManager.update_stat(
		get_network_master(), "kinetic", StatManager.players_stat[get_network_master()].dash_kin
	)
	_d = tween.start()

	# if state_machine.state.name != "Stabilize":


func physics_update(_delta):
	_d = player.move_and_slide(speed * direction)


func exit() -> void:
	_d = tween.stop_all()
	effect_timer.stop()


func _on_Timer_timeout() -> void:
	if state_machine.state.name != "Stabilize":
		state_machine.change_state("Idle")


func _end_dash(_o, _k) -> void:
	if state_machine.state.name != "Stabilize":
		state_machine.change_state("Idle")


func _cloning() -> void:
	var shad = _shadow.instance()
	var anim: AnimatedSprite = player.get_node("AnimatedSprite")
	shad.texture = anim.frames.get_frame(anim.animation, anim.frame)
	shad.position = player.position
	shad.position.y -= 26
	shad.scale = player.scale * 4
	player.get_parent().get_parent().add_child(shad)


func _on_collision(_area: Area2D):
	print("COLLIDE")
	state_machine.change_state("Idle", {})
