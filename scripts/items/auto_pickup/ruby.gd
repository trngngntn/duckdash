extends AutoPickUpItem


func _on_picked_up(peer_id: int) -> void:
	var change_val = StatManager.players_stat[peer_id].max_hp * 0.02
	StatManager.update_stat(peer_id, "max_hp", change_val)
	# StatManager.update_stat(peer_id, "atk_damage", 1)
