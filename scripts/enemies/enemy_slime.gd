extends Enemy

var flash_timer: Timer


func _get_custom_rpc_methods() -> Array:
	var func_list = ._get_custom_rpc_methods()
	func_list.append_array(
		[
			"hurt",
		]
	)
	return func_list


func init(nav: Navigation2D, _target: Node2D, _upd_timer: Timer):
	mv_speed = 180
	hp = 100
	target = _target
	self.movement_ai = LandEnemyMovementAI.new(self, nav)

	flash_timer = Timer.new()
	flash_timer.wait_time = .2
	flash_timer.one_shot = true
	flash_timer.connect("timeout", self, "_flash_timer_timeout")
	add_child(flash_timer)

	self.upd_timer = _upd_timer
	return self


func _ready():
	$AnimatedSprite.play("move")


func hurt() -> void:
	sprite.material.set_shader_param("enable", true)
	hp -= 50
	if hp <= 0:
		damageble = false
		movement_ai = null
	flash_timer.start()


func _flash_timer_timeout() -> void:
	sprite.material.set_shader_param("enable", false)
	if hp <= 0:
		queue_free()
