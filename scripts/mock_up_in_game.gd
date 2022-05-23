extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var duck
var mob_spawn_range = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	_initPlayer()
	randomize()
	$MobSpawnTimer.start()

func _initPlayer():
	duck = preload("res://scenes/duck.tscn").instance()
	var camera = Camera2D.new()
	camera.current = true
	duck.add_child(camera)
	add_child(duck)
	add_child_below_node($TileMap, duck)
	duck.position = get_viewport().size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("move_dash"):
		duck.dash()
	if Input.is_action_just_pressed("attack"):
		duck.shoot(get_viewport().get_mouse_position() - get_viewport().size / 2)
	pass


func _on_MobSpawnTimer_timeout():
	var rand_point = Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * mob_spawn_range + duck.position
	if $WallTileMap.get_cellv(rand_point) != TileMap.INVALID_CELL:
		var mob = preload("res://scenes/enemies/enemy_slime.tscn").instance()
		mob.position = rand_point
		add_child(mob)
	#randomize()
	

