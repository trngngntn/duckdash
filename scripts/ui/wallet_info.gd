extends Panel

func _ready():
	set_values()
	WalletManager.connect("fetch", self, "set_values")


func set_values() -> void:
	$HBoxContainer/Coin.text = "    " + str(WalletManager.gold) + " "
	$HBoxContainer/Soul.text = "    " + str(WalletManager.soul) + " "

