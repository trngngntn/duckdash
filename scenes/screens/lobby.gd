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

