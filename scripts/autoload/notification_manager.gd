extends Node

const DEFAULT_NOTIFICATION_TIMEOUT = 5


func _ready():
	#warning-ignore: return_value_discarded
	Conn.connect(
		"received_friend_request_notification", self, "_on_receiveFriendRequest_notification"
	)
	#warning-ignore: return_value_discarded
	Conn.connect("nakama_login_err", self, "_on_receiveLogin_error")
	#warning-ignore: return_value_discarded
	Conn.connect("register_err", self, "_on_receiveRegister_error")


func _on_receiveFriendRequest_notification(notification: NakamaAPI.ApiNotification):
	ScreenManager.show_notification(notification.subject, DEFAULT_NOTIFICATION_TIMEOUT)

func _on_receiveLogin_error(errorMessage: String):
	ScreenManager.show_notification(errorMessage, DEFAULT_NOTIFICATION_TIMEOUT)

func _on_receiveRegister_error(errorMessage: String):
	ScreenManager.show_notification(errorMessage, DEFAULT_NOTIFICATION_TIMEOUT)
