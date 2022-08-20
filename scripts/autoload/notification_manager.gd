extends Node

var current_id: int
onready var notif: Notification = ScreenManager.main.get_node("UI/Notification")


func _ready():
	Conn.connect(
		"received_friend_request_notification", self, "_on_receiveFriendRequest_notification"
	)

	Conn.connect("nakama_login_err", self, "_on_receiveLogin_error")

	Conn.connect("register_err", self, "_on_receiveRegister_error")


func show_notification(info: Dictionary):
	notif.show_notif(info["title"], info["content"])
	current_id = info["id"]


func show_custom_notification(title: String, content: String, auto_hide: bool = true):
	notif.show_notif(title, content, auto_hide)
	current_id = Notification.ID_CUSTOM_NOTIF

func hide_notification():
	notif.hide_notif()


func connect_pressed_signal(node: Node, method: String) -> void:
	notif.connect("pressed", node, method)


func _on_receiveFriendRequest_notification(notification: NakamaAPI.ApiNotification):
	notif.show_notification("Friend request", notification.subject)


func _on_receiveLogin_error(errorMessage: String):
	notif.show_notification("Error", errorMessage)


func _on_receiveRegister_error(errorMessage: String):
	notif.show_notification("Error", errorMessage)
