extends AutoPickUpItem


func _on_picked_up(peer_id: int) -> void:
	# var change_val = StatManager.players_stat[peer_id].atk_damage * 0.02
	# StatManager.update_stat(peer_id, "atk_damage", change_val)
	StatManager.update_stat(peer_id, "atk_damage", 1)
