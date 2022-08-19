class_name Notification extends Control

const DEFAULT_NOTIFICATION_TIMEOUT = 3
const ID_CUSTOM_NOTIF = 100

const NOTIF_NO_EQUIPMENT = {
	"title": "Equipment", "content": "Please select a weapon to play", "id": 110
}

var timer: Timer
onready var NotificationBody = get_node("NinePatchRect")
onready var title = $Title
onready var content = $Content

signal pressed


func _ready():
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timeout")
	timer.wait_time = DEFAULT_NOTIFICATION_TIMEOUT
	timer.one_shot = true
	add_child(timer)
	timer.start()


func append_node(screen: Node) -> void:
	NotificationBody.add_child(screen)


func show_notif(_title: String, _content: String, auto_hide: bool = true):
	title.text = _title
	content.text = _content
	get_tree().create_tween().tween_property(self, "rect_position:y", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_IN
	)
	if auto_hide:
		timer.start()


func hide_notif() -> void:
	get_tree().create_tween().tween_property(self, "rect_position:y", -rect_size.y, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)


func _on_timeout() -> void:
	hide_notif()


func _on_ButtonClose_pressed():
	hide_notif()


func _on_LinkButton_pressed():
	emit_signal("pressed")
