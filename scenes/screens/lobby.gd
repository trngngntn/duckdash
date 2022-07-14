extends Control


func _ready():
	NakamaMatch.connect("player_joined", self, "")
	NakamaMatch.connect("player_left", self, "")
	NakamaMatch.connect("player_status_changed", self, "")
	NakamaMatch.connect("match_ready", self, "")
	NakamaMatch.connect("match_not_ready", self, "")

func _on_StartGameButton_pressed():
	Conn.connect_nakama_socket()
	NakamaMatch.create_match(Conn.nkm_socket)

func _on_LeaveButton_pressed():
	ScreenManager.change_screen(ScreenManager.SCREEN_MENU)

func _on_WeaponSlot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				ScreenManager.change_screen(ScreenManager.SCREEN_CHANGE_EQUIP)


func _on_WingSlot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				ScreenManager.change_screen(ScreenManager.SCREEN_CHANGE_EQUIP)


func _on_ArmorSlot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				ScreenManager.change_screen(ScreenManager.SCREEN_CHANGE_EQUIP)


func _on_FeetSlot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				ScreenManager.change_screen(ScreenManager.SCREEN_CHANGE_EQUIP)
