extends Control

const TITLE = "MARKETPLACE                                         "
const item_res = preload("res://scenes/ui/listing_item.tscn")
var font = preload("res://resources/font/ui_font_small.tres")
var selected_listing_item: Listing
var current_tab = 0

onready var listing_cont = $"TabContainer/For sale"
onready var self_listing_cont = $"TabContainer/Your listing"

func _ready():
	MarketplaceManager.connect("update_marketplace", self, "update_market_item")
	update_market_item()

func update_market_item() -> void:
	var items = MarketplaceManager.get_listings()
	# for child in listing_cont.get_children():
	# 	listing_cont.remove_child(child)
	for equipment in items["market"]:
		add_item(equipment)
		
	for equipment in items["listing"]:
		add_my_listing_item(equipment)

func add_item(item: Listing) -> void:
	listing_cont.add_item(item)

func add_my_listing_item(item: Listing) -> void:
	self_listing_cont.add_child(item)

func _on_listing_item_selected(item: Listing):
	$Panel.visible = true
	selected_listing_item = item
	EquipmentManager.GetEquipmentDetail(item.item_raw)
	# var equipment = yield(EquipmentManager.self_instance, "got_equipment_detail")
	# set_equipment(equipment)


func _on_BuyButton_pressed():
	if selected_listing_item != null:
		$ConfirmationDialog.visible = true
		
func _on_ConfirmationDialog_confirmed():
	MarketplaceManager.buy_equipment(selected_listing_item)

func _on_TabContainer_tab_selected(tab):
	current_tab = tab
	if tab == 1:
		$Panel.visible = false
		
func _on_EditButton_pressed():
	ScreenManager.show_edit_listing_item_dialog(ScreenManager.DIALOG_EDIT_LISTING_ITEM, selected_listing_item)

func _on_DeleteButton_pressed():
	$DeleteListingItemDialog.visible = true

func _on_DeleteListingItemDialog_confirmed():
	MarketplaceManager.deleteListingItem(selected_listing_item)
