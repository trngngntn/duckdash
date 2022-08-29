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

	MarketplaceManager.connect("listing_added", self, "_on_listing_added")
	MarketplaceManager.connect("listing_added", self, "_on_listing_deleted")
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
	for listing in MarketplaceManager.listing_items["listing"].values():
		add_listing(listing)

	for listing in MarketplaceManager.listing_items["self_listing"].values():
		add_self_listing(listing)


func add_listing(listing: Listing) -> void:
	listing_cont.add_listing(listing)


func add_self_listing(listing: Listing) -> void:
	self_listing_cont.add_listing(listing)


func _on_listing_cleared():
	$InfoPanel.hide()
	unsqueeze()


func _on_listing_selected(item: ListingItem, is_self: bool):
	squeeze()
	$InfoPanel.show()
	$InfoPanel.self_listing = is_self
	$InfoPanel.equipment = item.listing.equipment


func _on_listing_added(type: String, listing: Listing) -> void:
	match type:
		"listing":
			add_listing(listing)
		"self_listing":
			add_self_listing(listing)


func _on_listing_deleted(_type, id) -> void:
	pass


func _on_BuyButton_pressed():
	var dialog = ScreenManager.show_confirm_dialog("Buy this equipment?")
	if dialog.is_connected("confirmed", self, "_on_ConfirmDialog_confirmed"):
		dialog.disconnect("confirmed", self, "_on_ConfirmDialog_confirmed")
	dialog.connect("confirmed", self, "_on_ConfirmDialog_confirmed", ["buy"])


func _on_EditButton_pressed():
	var dialog = ScreenManager.show_small_dialog(ScreenManager.DIALOG_EDIT_LISTING_ITEM)
	dialog.set_last_price(self_listing_cont.last_selected.listing.price)
	dialog.connect("result", self, "_on_edit_dialog_result")

func _on_edit_dialog_result(price: int) -> void:
	MarketplaceManager.edit_listing(self_listing_cont.last_selected.listing, price)

func _on_CancelButton_pressed():
	var dialog = ScreenManager.show_confirm_dialog("Cancel this listing?")
	if dialog.is_connected("confirmed", self, "_on_ConfirmDialog_confirmed"):
		dialog.disconnect("confirmed", self, "_on_ConfirmDialog_confirmed")
	dialog.connect("confirmed", self, "_on_ConfirmDialog_confirmed", ["cancel"])


func _on_ConfirmDialog_confirmed(type: String):
	match type:
		"buy":
			MarketplaceManager.buy_equipment(listing_cont.last_selected.listing)
		"cancel":
			MarketplaceManager.delete_listing(self_listing_cont.last_selected.listing)


func _on_TabContainer_tab_changed(tab: int):
	$InfoPanel.hide()
	match tab:
		0:
			self_listing_cont.unselect()
		1:
			listing_cont.unselect()
