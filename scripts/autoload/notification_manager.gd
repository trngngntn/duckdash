extends Node

var receive_friend_request_notification = load("res://scenes/screens/notification/receive_friend_request.tscn")

func _ready():
	#warning-ignore: return_value_discarded
	Conn.connect("received_friend_request_notification", self, "_on_receiveFriendRequest_notification")

func _on_receiveFriendRequest_notification(notification : NakamaAPI.ApiNotification):
	ScreenManager.show_notification(receive_friend_request_notification, notification)
