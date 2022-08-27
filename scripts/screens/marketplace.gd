extends Control

const TITLE = "MARKETPLACE                                         "
const item_res = preload("res://scenes/ui/listing_item.tscn")
var font = preload("res://resources/font/ui_font_small.tres")
var current_tab = 0

onready var listing_cont = $"TabContainer/For sale"
onready var self_listing_cont = $"TabContainer/Your listing"


func _ready():
	listing_cont.connect("listing_selected", self, "_on_listing_selected", [false])
	listing_cont.connect("listing_cleared", self, "_on_listing_cleared")
	self_listing_cont.connect("listing_selected", self, "_on_listing_selected", [true])
	self_listing_cont.connect("listing_cleared", self, "_on_listing_cleared")
	# for container in $TabContainer.get_children():
	# 	connect("squeezed", container, "_on_squeezed")
	MarketplaceManager.connect("update_marketplace", self, "update_market_item")
	update_market_item()


func squeeze() -> void:
	$TabContainer.anchor_right = 0.7
	$TabContainer.margin_right = -32
	# emit_signal("squeezed")


func unsqueeze() -> void:
	$TabContainer.anchor_right = 1
	$TabContainer.margin_right = 0
	# emit_signal("unsqueezed")


func update_market_item() -> void:
	var items = MarketplaceManager.get_listings()
	# for child in listing_cont.get_children():
	# 	listing_cont.remove_child(child)
	for listing in items["market"]:
		add_item(listing)

	for listing in items["listing"]:
		add_self_listing_item(listing)


func add_item(listing: Listing) -> void:
	listing_cont.add_item(listing)


func add_self_listing_item(listing: Listing) -> void:
	self_listing_cont.add_item(listing)


func _on_listing_cleared():
	$InfoPanel.hide()
	unsqueeze()


func _on_listing_selected(item: ListingItem, is_self: bool):
	squeeze()
	$InfoPanel.show()
	$InfoPanel.self_listing = is_self
	$InfoPanel.equipment = item.listing.equipment


func _on_BuyButton_pressed():
	$ConfirmationDialog.visible = true


func _on_ConfirmationDialog_confirmed():
	MarketplaceManager.buy_equipment(listing_cont.last_selected.listing)


func _on_EditButton_pressed():
	ScreenManager.show_edit_listing_dialog(
		ScreenManager.DIALOG_EDIT_LISTING_ITEM, self_listing_cont.last_selected.listing
	)


func _on_CancelButton_pressed():
	$DeleteListingItemDialog.visible = true


func _on_delete_listingDialog_confirmed():
	MarketplaceManager.delete_listing(self_listing_cont.last_selected.listing)


func _on_TabContainer_tab_changed(tab: int):
	$InfoPanel.hide()
	match tab:
		0:
			self_listing_cont.unselect()
		1:
			listing_cont.unselect()
