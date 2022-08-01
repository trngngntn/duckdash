extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var path = []
var speed = 200
var hp = 200
onready var nav = get_node("../../../Navigation")


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
	path = nav.get_simple_path(
		position, get_parent().get_child(0).position
	)
	path.remove(0)
	set_process(true)


func _on_PathfindTimer_timeout():
	_update_path()


func _on_Slime_area_entered(area):
	pass
