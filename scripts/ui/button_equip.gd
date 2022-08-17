extends TextureButton

var tex_slot = preload("res://assets/sprites/static/ui/ui_slot_shallow.png")
var tex_add_norm = preload("res://assets/sprites/static/ui/ui_slot_add_normal.png")
var tex_add_press = preload("res://assets/sprites/static/ui/ui_slot_add_pressed.png")

var equipment: Equipment
var mode: bool = false


func _ready():
	pass  # Replace with function body.


func toggle_mode():
	mode = not mode
	if mode:
		texture_pressed = null
		texture_normal = tex_slot
	else:
		texture_pressed = tex_add_press
		texture_normal = tex_add_norm


func set_equipment(_equipment: Equipment) -> void:
	equipment = _equipment
