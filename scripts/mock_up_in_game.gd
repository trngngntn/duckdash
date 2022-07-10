extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var duck: KinematicBody2D
var camera


# Called when the node enters the scene tree for the first time.
func _ready():
	_init_player()


func _init_player():
	duck = preload("res://scenes/character/duck.tscn").instance()
	camera = Camera2D.new()
	camera.current = true
	add_child(camera)
	$Stage/YSort.add_child(duck)
	duck.add_to_group("duck")
	duck.position = get_viewport().size / 2
	camera.position = duck.position
	# duck.visible = false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("move_dash"):
		duck.dash()
	if Input.is_action_just_pressed("attack"):
		var mouse = get_viewport().get_mouse_position() - get_viewport().size / 2
		mouse.x /= 2
		duck.shoot(mouse)


func _physics_process(delta):
	#camera.position = camera.position.linear_interpolate(duck.position, delta * 8)
	$Tween.interpolate_property(
		camera,
		"position",
		camera.position,
		duck.position,
		delta * 20,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	$Tween.start()
