extends Node

const SCREEN_LOGIN = preload("res://scenes/screens/sign_in.tscn")
const SCREEN_REGISTER = preload("res://scenes/screens/sign_up.tscn")
const SCREEN_MENU = preload("res://scenes/screens/main_menu.tscn")
const SCREEN_LOBBY = preload("res://scenes/screens/lobby.tscn")
const SCREEN_INGAME = preload("res://scenes/screens/in_game.tscn")
const SCREEN_CHANGE_EQUIP = preload("res://scenes/screens/equipment_changing.tscn")
const SCREEN_INVENTORY = preload("res://scenes/screens/inventory.tscn")
const SCREEN_MARKETPLACE = preload("res://scenes/screens/market_place.tscn")

onready var main: Node = get_tree().current_scene
onready var screen: Node = main.get_node("Screen")
onready var ui: Control = main.get_node("UI")
var current_screen : Node
onready var self_instance = self


func _ready() -> void:
	var _result := Conn.connect("dev_auth", self, "_on_NakamaConn_device_authorized")
	_result = Conn.connect("dev_unauth", self, "_on_NakamaConn_device_unauthorized")
	Conn.device_auth()


func change_screen(screen_res: Resource) -> Node:
	if not screen:
		return null
	if screen.get_child_count() > 0:
		for child in screen.get_children():
			child.queue_free()
	current_screen = screen_res.instance()
	print("SCRN_MAN: change screen")
	screen.add_child(current_screen)
	return current_screen


func connect_signal(signal_name: String, method: String) -> void:
	var result = connect(signal_name, self, method)
	if result != OK:
		print("SCRN_MAN_ERR: cannot connect signal")


####
# NamakaMatch callbacks
func _on_NakamaConn_device_authorized() -> void:
	var _scr := change_screen(ScreenManager.SCREEN_MENU)

func _on_NakamaConn_device_unauthorized() -> void:
	var _scr := change_screen(ScreenManager.SCREEN_LOGIN)

