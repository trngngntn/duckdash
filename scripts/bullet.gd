extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var direction
var init_position
var speed = 800
var decay = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("fly")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if init_position.distance_to(position) > decay:
		queue_free()
	else:
		position += direction * speed * delta

func set_direction(pos, dir):
	direction = dir.normalized()
	rotation = dir.angle()
	init_position = pos
	position = pos


func _on_Bullet_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	queue_free()


func _on_Bullet_area_entered(area):
	queue_free()
