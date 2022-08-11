extends Control

const TITLE = "Profile"

const friend_request_dialog = preload("res://scenes/screens/dialog/friend_request_dialog.tscn")
const add_friend_dialog = preload("res://scenes/screens/dialog/add_friend_dialog.tscn")
const edit_profile_dialog = preload("res://scenes/screens/dialog/edit_profile_dialog.tscn")
const friend_node = preload("res://scenes/screens/friend/friend_item.tscn")

onready var grid_container = get_node("TabContainer/Friends/VBoxContainer/ScrollContainer/GridContainer")
onready var profile_username_label = get_node("TabContainer/Profile/Panel/DisplayNameLabel")
onready var profile_id_label = get_node("TabContainer/Profile/Panel/UserIDLabel")
onready var profile_email_label = get_node("TabContainer/Profile/Panel/UserEmailLabel")

func _ready():
	load_user_profile()

func load_user_profile():
	var account : NakamaAPI.ApiAccount = yield(Conn.nkm_client.get_account_async(Conn.nkm_session), "completed")
	
	if account.is_exception():
		print("An error occurred: %s" % account)
		return
		
	var user = account.user
	
	profile_username_label.text = user.username
	profile_id_label.text = user.id
	profile_email_label.text = account.email

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func loadFriendList():
	delete_children(grid_container)
	var list : NakamaAPI.ApiFriendList = yield(Conn.nkm_client.list_friends_async(Conn.nkm_session, 0), "completed")

	if list.is_exception():
		print("An error occurred: %s" % list)
		return
			
	for f in list.friends:
		var friend = f as NakamaAPI.ApiFriend
		var friend_item = friend_node.instance()
		
		grid_container.add_child(friend_item)
		
		friend_item.set_friend_id(friend.user.id)
		friend_item.set_friend_name(friend.user.username)
		friend_item.set_friend_status(friend.user.online)

func _on_TabContainer_tab_changed(tab):
	match tab:
		1:
			loadFriendList()

func _on_Button2_pressed():
	ScreenManager.show_screen_dialog(friend_request_dialog)

func _on_Button_pressed():
	ScreenManager.show_screen_dialog(add_friend_dialog)

func _on_TextureButton_pressed():
	var scrn = ScreenManager.show_small_dialog(edit_profile_dialog)
	scrn.connect("edit_username_success", self, "load_user_profile")
