extends Control
class_name Dialog

func _ready():
	pass # Replace with function body.

func set_title(title: String) -> void:
	$Title.text = title

func append_node(screen: Node) -> void:
	$Control.add_child(screen)

func close() -> void:
	if $Control.get_child_count() > 0:
		for child in $Control.get_children():
			child.queue_free()

func _on_ButtonClose_pressed():
	close()
	hide()
