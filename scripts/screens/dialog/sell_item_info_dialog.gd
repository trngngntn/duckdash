extends Control

var TITLE = "Enter your price: (gold)"

var equipment

func setEquipmentHash(_equipment: Equipment):
	equipment = _equipment

func _ready():
	pass # Replace with function body.

func _on_SubmitButton_pressed():
	var price = $VBoxContainer/PriceInput.text
	if !price || !price.is_valid_integer():
		NotificationManager.show_custom_notification("Error", "Please enter valid price!")
	else:
		$ConfirmationDialog.visible = true

func _on_ConfirmationDialog_confirmed():
	var price = $VBoxContainer/PriceInput.text
	MarketplaceManager.list_equipment_to_market(equipment, int(price))
