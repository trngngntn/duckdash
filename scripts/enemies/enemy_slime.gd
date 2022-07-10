extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var path = []
var speed = 200
var hp = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("move")
	_update_path()
	$PathfindTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist = speed * delta
	_move_along_path(dist)

func _move_along_path(distance):
	var last_point = position
	while path.size():
		var move_distance = last_point.distance_to(path[0])
		if distance <= move_distance:
			position = last_point.linear_interpolate(path[0], distance / move_distance)
			#move_and_slide()
			return
		distance -= move_distance
		last_point = path[0]
		path.remove(0)
	position = last_point
	set_process(false)

func _update_path():
	path = get_node("../../Navigation").get_simple_path(position, get_tree().get_nodes_in_group("duck").front().position)
	path.remove(0)
	set_process(true)


func _on_PathfindTimer_timeout():
	if(position.distance_to(get_tree().get_nodes_in_group("duck").front().position) < 1500):
		_update_path()


func _on_Slime_area_entered(area):
	hp -= 100
	if hp <= 0:
		queue_free()
