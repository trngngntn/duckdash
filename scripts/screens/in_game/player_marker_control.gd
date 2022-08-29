extends Control

const MARKER_RES = preload("res://scenes/screens/in_game/marker.tscn")

func _ready():
	pass # Replace with function body.

func setup(self_player, player_list: Array):
	for player in player_list:
		if player != self_player:
			var marker = MARKER_RES.instance()
			marker.pivot_node = self_player
			marker.target_node = player
			$Cont.add_child(marker)
