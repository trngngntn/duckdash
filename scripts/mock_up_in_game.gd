extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var duck
var mob_spawn_range = 1200

# Called when the node enters the scene tree for the first time.
func _ready():
	_initPlayer()
	randomize()
	$MobSpawnTimer.start()
	#print($WallTileMap.get_cellv(Vector2(-1,0)))

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
	var rand_point = duck.position + Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * mob_spawn_range
	while $WallTileMap.get_cell(floor((rand_point.x - 64) / 128), floor(rand_point.y / 128)) != TileMap.INVALID_CELL:
		rand_point = duck.position + Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * mob_spawn_range
	var mob = preload("res://scenes/enemies/enemy_slime.tscn").instance()
	mob.position = rand_point
	add_child(mob)
	#randomize()
	

