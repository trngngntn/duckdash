extends Panel

var friend_id = null
onready var status_label = get_node("MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/HBoxContainer/Status")
onready var name_label = get_node("MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/FriendName")

func set_friend_name(name: String) -> void:
	name_label.text = name
	
func set_friend_id(id: String) -> void:
	friend_id = id
	
func set_friend_status(online: bool) -> void:
	var status = 'Offline'
	if online == true:
		status = 'Online'
	
	status_label.text = status

func remove_from_list_request():
	for n in self.get_children():
		self.remove_child(n)
		self.queue_free()
	self.remove_and_skip()

func _on_DeleteButton_pressed():
	var ids = [friend_id]
	var usernames = []
	var remove : NakamaAsyncResult = yield(Conn.nkm_client.delete_friends_async(Conn.nkm_session, ids, usernames), "completed")

	if remove.is_exception():
		print("An error occurred: %s" % remove)
		return
		
	remove_from_list_request()

func _on_AcceptButton_pressed():
	var ids = [friend_id]
	var usernames = []
	var add : NakamaAsyncResult = yield(Conn.nkm_client.add_friends_async(Conn.nkm_session, ids, usernames), "completed")

	if add.is_exception():
		print("An error occurred: %s" % add)
		return
		
	remove_from_list_request()
	
func _ready():
	pass
