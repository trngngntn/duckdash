extends Panel


func _ready():
	StatManager.connect("stat_change", self, "_on_stat_change")


func _on_stat_change(stat_name: String, _change, new_value) -> void:
	print("LOG:   " + stat_name)
	match stat_name:
		"coin":
			$VBoxContainer/GoldCount.text = str(new_value)
		"soul":
			$VBoxContainer/SoulCount.text = str(new_value)
