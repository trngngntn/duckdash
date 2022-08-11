extends Control

var friend_request_dialog = load("res://scenes/screens/dialog/friend_request_dialog.tscn")

onready var noti_content = get_node("Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_notification_content(content: String):
	$Label.text = content
	print($Label.text)


func _on_TextureButton_pressed():
	ScreenManager.show_screen_dialog(friend_request_dialog)
