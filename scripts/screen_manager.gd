extends Node

const SCREEN_LOGIN = preload("res://scenes/screens/sign_in.tscn")
const SCREEN_REGISTER = preload("res://scenes/screens/sign_up.tscn")
const SCREEN_MENU = preload("res://scenes/screens/main_menu.tscn")
const SCREEN_LOBBY = preload("res://scenes/screens/lobby.tscn")
const SCREEN_INVENTORY = preload("res://scenes/screens/inventory.tscn")
const SCREEN_MARKETPLACE = preload("res://scenes/screens/market_place.tscn")

onready var main : Node = get_tree().current_scene
onready var screen : Node = main.get_node("Screen")
onready var ui : Control = main.get_node("UI")

func _ready():
	Conn.connect("dev_auth", self, "_on_NakamaConn_device_authorized")
	Conn.connect("dev_unauth", self, "_on_NakamaConn_device_unauthorized")
	Conn.device_auth()

func change_screen(screen_res: Resource):
	if screen.get_child_count() > 0:
		for child in screen.get_children():
			child.queue_free()
	print("SCRN_MAN: change screen")
	screen.add_child(screen_res.instance())

func _on_NakamaConn_device_authorized() -> void:
	change_screen(ScreenManager.SCREEN_MENU)
	
func _on_NakamaConn_device_unauthorized() -> void:
	change_screen(ScreenManager.SCREEN_LOGIN)
	
