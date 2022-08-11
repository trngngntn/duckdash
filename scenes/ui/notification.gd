extends Control

var timer = Timer.new()
onready var NotificationBody = get_node("NinePatchRect")
onready var NotificationLabel = get_node("NinePatchRect/Label")

func _ready():
	timer.connect("timeout", self, "set_time_remove")
	timer.wait_time = 3
	timer.one_shot = true
	add_child(timer)
	timer.start()

func append_node(screen: Node) -> void:
	 NotificationBody.add_child(screen)

func set_notification_label(content: String):
	NotificationLabel.text = content

func remove_notification() -> void:
	hide()

func set_time_remove(second: int) -> void:
	timer.connect("timeout", self, "remove_notification")
	timer.wait_time = second
	add_child(timer)
	timer.start()
