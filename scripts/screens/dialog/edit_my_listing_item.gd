extends Control

var TITLE = "Enter your price: (gold)"

var listing

func set_lising(_listing: Listing):
	listing= _listing
	$VBoxContainer/PriceInput.text = listing.price

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
	MarketplaceManager.edit_listing(listing, int(price))
