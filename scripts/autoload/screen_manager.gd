extends Node

const SCREEN_LOGIN = preload("res://scenes/screens/sign_in.tscn")
const SCREEN_REGISTER = preload("res://scenes/screens/sign_up.tscn")
const SCREEN_MENU = preload("res://scenes/screens/main_menu.tscn")
const SCREEN_LOBBY = preload("res://scenes/screens/lobby.tscn")
const SCREEN_INGAME = preload("res://scenes/screens/in_game.tscn")
const SCREEN_CHANGE_EQUIP = preload("res://scenes/screens/equipment_changing.tscn")
const SCREEN_INVENTORY = preload("res://scenes/screens/inventory.tscn")
const SCREEN_MARKETPLACE = preload("res://scenes/screens/market_place.tscn")
const SCREEN_PROFILE = preload("res://scenes/screens/profile_screen.tscn")

const SCREEN_EQUIPMENT_CRAFTING = preload("res://scenes/screens/dialog/equipment_crafting.tscn")

var screen_res_stack: Array = []
var current_screen: Node

signal screen_changed(screen)
signal go_back

onready var main: Node = get_tree().current_scene
onready var screen: Node = main.get_node("Screen")
onready var ui: CanvasLayer = main.get_node("UI")
onready var dialog: Dialog = main.get_node("UI/Dialog")
onready var small_dialog: Dialog = main.get_node("UI/SmallDialog")


onready var self_instance = self


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	var _result := Conn.connect("dev_auth", self, "_on_NakamaConn_device_authorized")
	_result = Conn.connect("dev_unauth", self, "_on_NakamaConn_device_unauthorized")
	_result = Conn.connect("nakama_logged_in", self, "_on_NakamaConn_logged_in")
	_result = Conn.connect("registered", self, "_on_NakamaConn_registered")
	_result = main.connect("go_back", self, "_on_ScreenManager_go_back_pressed")
	Conn.device_auth()


func show_small_dialog(screen_res: Resource) -> Node:
	var scrn = screen_res.instance()
	small_dialog.append_node(scrn)
	small_dialog.set_title(str(scrn.get("TITLE")))
	small_dialog.show()
	return scrn



func show_screen_dialog(screen_res: Resource) -> Node:
	var scrn = screen_res.instance()
	dialog.append_node(scrn)
	dialog.set_title(str(scrn.get("TITLE")))
	dialog.show()
	return scrn


func change_screen(screen_res: Resource, go_back := true) -> Node:
	if not screen:
		return null

	if screen.get_child_count() > 0:
		for child in screen.get_children():
			if child.has_method("exit"):
				child.exit()
			else:
				child.queue_free()
	current_screen = screen_res.instance()
	print("[LOG][SCREEN_MAN]Change screen")
	screen.add_child(current_screen)

	main.show_background()

	if screen_res == SCREEN_INGAME:
		go_back = false
		main.hide_background()
		main.hide_titlebar()
	elif screen_res == SCREEN_MENU:
		main.hide_titlebar()
		go_back = false
	else:
		main.show_titlebar()
		main.set_title(str(current_screen.get("TITLE")))

	if screen_res_stack.back() != screen_res:
		screen_res_stack.push_back(screen_res)

	if screen_res_stack.size() <= 1:
		go_back = false
	elif not go_back:
		screen_res_stack.clear()

	main.back = go_back

	emit_signal("screen_changed")
	print(screen_res_stack.size())

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
	emit_signal("go_back")


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
