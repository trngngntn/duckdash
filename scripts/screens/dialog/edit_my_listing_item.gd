extends Control

var TITLE = "Enter your price: (gold)"

var listing

signal result(price)

func set_last_price(price: int):
	$VBoxContainer/PriceInput.text = str(price)


func _on_SubmitButton_pressed():
	var price = $VBoxContainer/PriceInput.text
	if !price || !price.is_valid_integer():
		NotificationManager.show_custom_notification("Error", "Please enter valid price!")
	else:
		ScreenManager.show_confirm_dialog("Change listing price to %d gold?" % int(price)).connect(
			"confirmed", self, "_on_ConfirmDialog_confirmed"
		)


func _on_ConfirmDialog_confirmed():
	var price = $VBoxContainer/PriceInput.text
	emit_signal("result", int(price))
	ScreenManager.small_dialog.hide()
