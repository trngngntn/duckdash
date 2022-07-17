extends Node

const SCREEN_LOGIN = preload("res://scenes/screens/sign_in.tscn")
const SCREEN_REGISTER = preload("res://scenes/screens/sign_up.tscn")
const SCREEN_MENU = preload("res://scenes/screens/main_menu.tscn")
const SCREEN_LOBBY = preload("res://scenes/screens/lobby.tscn")
const SCREEN_INGAME = preload("res://scenes/screens/in_game.tscn")
const SCREEN_CHANGE_EQUIP = preload("res://scenes/screens/equipment_changing.tscn")
const SCREEN_INVENTORY = preload("res://scenes/screens/inventory.tscn")
const SCREEN_MARKETPLACE = preload("res://scenes/screens/market_place.tscn")

var screen_res_stack: Array = []
var current_screen: Node

onready var main: Node = get_tree().current_scene
onready var screen: Node = main.get_node("Screen")
onready var ui: CanvasLayer = main.get_node("UI")
onready var self_instance = self


func _ready() -> void:
	var _result := Conn.connect("dev_auth", self, "_on_NakamaConn_device_authorized")
	_result = Conn.connect("dev_unauth", self, "_on_NakamaConn_device_unauthorized")
	_result = Conn.connect("logged_in", self, "_on_NakamaConn_logged_in")
	_result = Conn.connect("registered", self, "_on_NakamaConn_registered")
	_result = main.connect("go_back", self, "_on_ScreenManager_go_back_pressed")
	Conn.device_auth()


func change_screen(screen_res: Resource, go_back := true) -> Node:
	if not screen:
		return null

	if screen.get_child_count() > 0:
		for child in screen.get_children():
			child.queue_free()
	current_screen = screen_res.instance()
	print("SCRN_MAN: change screen")
	screen.add_child(current_screen)

	if screen_res == SCREEN_INGAME:
		main.hide_background()
	else:
		main.show_background()

	if screen_res == SCREEN_MENU:
		main.hide_titlebar()
		go_back = false
		screen_res_stack.clear()
	else:
		main.set_title(str(current_screen.get("TITLE")))

	if screen_res_stack.back() != screen_res:
		screen_res_stack.push_back(screen_res)

	if screen_res_stack.size() <= 1:
		go_back = false
	elif not go_back:
		screen_res_stack.clear()

	main.go_back = go_back

	return current_screen


func change_previous_screen() -> Node:
	if screen_res_stack.size() > 1:
		screen_res_stack.pop_back()
		return change_screen(screen_res_stack.back())
	else:
		return null


func connect_signal(signal_name: String, method: String) -> void:
	var result = connect(signal_name, self, method)
	if result != OK:
		print("SCRN_MAN_ERR: cannot connect signal")


func _on_ScreenManager_go_back_pressed() -> void:
	var _srcn = change_previous_screen()


####
# NamakaMatch callbacks
func _on_NakamaConn_device_authorized() -> void:
	var _scr := change_screen(ScreenManager.SCREEN_MENU)


func _on_NakamaConn_device_unauthorized() -> void:
	var _scr := change_screen(ScreenManager.SCREEN_LOGIN)

func _on_NakamaConn_logged_in() -> void:
	var _scr := change_screen(ScreenManager.SCREEN_MENU)

func _on_NakamaConn_registered() -> void:
	var _scr := change_screen(ScreenManager.SCREEN_MENU)
