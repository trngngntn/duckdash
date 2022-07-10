extends DuckState

var destination: Vector2
var tween : Tween
var timer : Timer

var _shadow = preload("res://scenes/character/duck_dash_shadow.tscn")

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)
	var _flag = tween.connect("tween_started", self, "_start_dash")

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = .003
	_flag = timer.connect("timeout", self, "_cloning")
	

func enter(dat := {}) -> void:
	
	destination = dat.direction * player.dash_range + player.position
	
	tween.interpolate_property(
		player,
		"position",
		player.position,
		destination,
		player.dash_range / player.dash_speed,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween.start()
	timer.start()

	if(dat.direction.x > 0):
		player.get_node("AnimatedSprite").play("dash_right")
	else:
		player.get_node("AnimatedSprite").play("dash_left")

func exit() -> void:
	timer.stop()

func _end_dash(_o, _k) -> void:
	state_machine.change_state("Idle")

func _cloning() -> void:
	var shad = _shadow.instance()
	var anim : AnimatedSprite = player.get_node("AnimatedSprite")
	shad.texture = anim.frames.get_frame(anim.animation, anim.frame)
	shad.position = player.position
	shad.scale = player.scale * 4
	player.get_parent().add_child(shad)
