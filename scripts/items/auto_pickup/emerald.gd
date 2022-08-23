extends AutoPickUpItem


func _on_picked_up(peer_id: int) -> void:
	var stat = StatManager.players_stat[peer_id]
	var change_val = clamp(stat.kin_thres * 0.25, 0, abs(stat.kinetic))
	if stat.kinetic > 0:
		change_val = -change_val
	StatManager.update_stat(peer_id, "kinetic", change_val)
