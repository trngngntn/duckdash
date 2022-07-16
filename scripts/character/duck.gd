extends KinematicBody2D
class_name Duck

var direction : Vector2
var speed : float = 300
var dash_speed : float= 1200
var dash_range : float = 400
var is_dashing = false
var dash_dest : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.

func set_player_name(name: String) -> void:
	$Label.text = name

func _update_position() -> void:
	if is_dashing:
		if (
			dash_dest.distance_to(position) < 10
			|| move_and_collide((dash_dest - position).normalized() * dash_speed)
		):
			is_dashing = false
	else:
		direction = Vector2()
		if OS.get_name() == "Android":
			pass
		else:
			if Input.is_action_pressed("move_up"):
				direction.y -= 1
			if Input.is_action_pressed("move_down"):
				direction.y += 1
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
			if Input.is_action_pressed("move_right"):
				direction.x += 1

		if direction.length() > 0:
			if direction.x > 0:
				$AnimatedSprite.play("move_right")
			else:
				$AnimatedSprite.play("move_left")
			direction = direction.normalized()
			move_and_slide(direction * speed)
		else:
			$AnimatedSprite.stop()


func dash() -> void:
	dash_dest = direction * dash_range + position
	is_dashing = true


func shoot(dir) -> void:
	var bullet = preload("res://scenes/bullet.tscn")
	var binst = bullet.instance()
	binst.set_direction(position + dir.normalized() * 100, dir)
	get_parent().add_child(binst)

	binst = bullet.instance()
	binst.set_direction(
		position + dir.normalized().rotated(PI / 9) * 100, dir.normalized().rotated(PI / 9)
	)
	get_parent().add_child(binst)

	binst = bullet.instance()
	binst.set_direction(
		position + dir.normalized().rotated(-PI / 9) * 100, dir.normalized().rotated(-PI / 9)
	)
	get_parent().add_child(binst)
