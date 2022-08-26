extends Control

var TITLE = "Enter your price: (gold)"

var listing_item

func setLisingItem(_listing_item: MarketListingItem):
	listing_item = _listing_item
	$VBoxContainer/PriceInput.text = listing_item.price

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
	MarketplaceManager.editListingItem(listing_item, int(price))
