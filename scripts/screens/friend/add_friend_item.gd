extends Panel

var friend_id = null
onready var friend_name = get_node("MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/FriendName")
onready var friend_status = get_node("MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/HBoxContainer/Status")
onready var request_label = get_node("MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Label")
onready var add_friend_button = get_node("MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/AddFriendButton")

func _ready():
	request_label.visible = false
	$MarginContainer.modulate.a = 0

func set_friend_name(name: String) -> void:
	friend_name.text = name
	
func set_friend_id(id: String) -> void:
	$MarginContainer.modulate.a = 1
	friend_id = id
	
func set_friend_status(online: bool) -> void:
	var status = 'offline'
	if online == true:
		status = 'online'
	
	friend_status.text = status

func remove_from_list_request():
	add_friend_button.visible = false
	request_label.visible = true

func _on_AddFriendButton_pressed():
	var ids = [friend_id]
	var result : NakamaAsyncResult = yield(Conn.nkm_client.add_friends_async(Conn.nkm_session, ids), "completed")
	remove_from_list_request()
