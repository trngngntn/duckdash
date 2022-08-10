extends MarginContainer

const TITLE = "FRIEND REQUEST"
var friend_request_item = load("res://scenes/screens/friend/friend_request_item.tscn")
onready var grid_container = get_node("VBoxContainer/ScrollContainer/GridContainer")

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func load_friend_request():
	delete_children(grid_container)
	var list : NakamaAPI.ApiFriendList = yield(Conn.nkm_client.list_friends_async(Conn.nkm_session, 2), "completed")
	if list.is_exception():
		print("An error occurred: %s" % list)
		return
			
	for f in list.friends:
		var friend = f as NakamaAPI.ApiFriend
		var friend_request = friend_request_item.instance()
		
		grid_container.add_child(friend_request)
		
		friend_request.set_friend_id(friend.user.id)
		friend_request.set_friend_name(friend.user.username)
		friend_request.set_friend_status(friend.user.online)
		
	
func _ready():
	load_friend_request()
