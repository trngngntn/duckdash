extends MarginContainer

const TITLE = "ADD FRIEND"
onready var username_input = get_node("VBoxContainer/HBoxContainer/LineEdit")
onready var friend_request_item = load("res://scenes/screens/friend/add_friend_item.tscn")
onready var friend_grid_container = get_node("VBoxContainer/ScrollContainer/GridContainer")

func _ready():
	pass # Replace with function body.

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func search_and_load_player_by_username(input: String) -> void:
	delete_children(friend_grid_container)
	var usernames = [input]
	var ids = []
	var result : NakamaAPI.ApiUsers = yield(Conn.nkm_client.get_users_async(Conn.nkm_session, ids, usernames), "completed")

	if result.is_exception():
		print("An error occurred: %s" % result)
		return

	for user in result.users:
		var found_user = friend_request_item.instance()
		friend_grid_container.add_child(found_user)
		
		found_user.set_friend_id(user.id)
		found_user.set_friend_name(user.username)
		found_user.set_friend_status(user.online)
		

func _on_Button_pressed():
	search_and_load_player_by_username(username_input.text)

func _on_LineEdit_focus_entered():
	if username_input.text == "Searchbox":
		username_input.text = ""
