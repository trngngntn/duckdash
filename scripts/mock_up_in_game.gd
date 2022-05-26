extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var duck


# Called when the node enters the scene tree for the first time.
func _ready():
	_initPlayer()

func _initPlayer():
	duck = preload("res://scenes/duck.tscn").instance()
	var camera = Camera2D.new()
	camera.current = true
	duck.add_child(camera)
	$Stage/YSort.add_child(duck)
	duck.add_to_group("duck")
	duck.position = get_viewport().size / 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("move_dash"):
		duck.dash()
	if Input.is_action_just_pressed("attack"):
		duck.shoot(get_viewport().get_mouse_position() - get_viewport().size / 2)
