extends AutoPickUpItem


func _on_picked_up(peer_id: int) -> void:
	StatManager.update_stat(peer_id, "coin", 1)
