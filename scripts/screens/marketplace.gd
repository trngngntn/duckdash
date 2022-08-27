extends Control

const TITLE = "MARKETPLACE                                         "
const item_res = preload("res://scenes/items/listing_item.tscn")
var font = preload("res://resources/font/ui_font_small.tres")
var selected_listing_item: MarketListingItem
var current_tab = 0

onready var listing_cont = $TabContainer/Market/ScrollContainer/ListingContainer
onready var my_listing_cont = $TabContainer/MyListing/ScrollContainer/MyListingContainer

func _ready():
	MarketplaceManager.connect("update_marketplace", self, "update_market_item")
	update_market_item()

func update_market_item() -> void:
	var items = MarketplaceManager.getMarketListingItem()
	for child in listing_cont.get_children():
		listing_cont.remove_child(child)
	for equipment in items["market"]:
		add_item(equipment)
		
	for equipment in items["listing"]:
		add_my_listing_item(equipment)

func add_item(item: MarketListingItem) -> void:
	var new_item = item_res.instance()
	new_item.setProperties(item)
	new_item.connect("listing_item_selected", self, "_on_listing_item_selected")
	listing_cont.add_child(new_item)

func add_my_listing_item(item: MarketListingItem) -> void:
	var new_item = item_res.instance()
	new_item.setProperties(item)
	new_item.connect("listing_item_selected", self, "_on_listing_item_selected")
	my_listing_cont.add_child(new_item)

func _on_listing_item_selected(item: MarketListingItem):
	$Panel.visible = true
	selected_listing_item = item
	EquipmentManager.GetEquipmentDetail(item.item_raw)
	var equipment = yield(EquipmentManager.self_instance, "got_equipment_detail")
	set_equipment(equipment)

func set_equipment(equipment: Equipment) -> void:
	for child in $Panel/ScrollContainer/VBoxContainer/StatList.get_children():
		$Panel/ScrollContainer/VBoxContainer/StatList.remove_child(child)

	$Panel/ScrollContainer/VBoxContainer/Name.text = Equipment.TYPE[equipment.type_name]["display"]

	var label := Label.new()
	label.set("custom_fonts/font", font)
	# label.text = "Tier: " + equipment.tier
	if equipment.sub_type && equipment.sub_type != "":
		label.text = equipment.SUB_TYPE[equipment.sub_type]["name"]
		label.align = Label.ALIGN_CENTER
	$Panel/ScrollContainer/VBoxContainer/StatList.add_child(label)

	$Panel/ScrollContainer/VBoxContainer/Control/InventoryItem.equipment = equipment

	for stat in equipment.stat:
		label = Label.new()
		label.set("custom_fonts/font", font)
		label.text = StatManager.stat_info_list[stat.stat_id]["format"] % stat.value
		$Panel/ScrollContainer/VBoxContainer/StatList.add_child(label)
		
	if current_tab == 0:
		$Panel/BuyButton.visible = true
		$Panel/EditButton.visible = false
		$Panel/DeleteButton.visible = false
	
	if current_tab == 1:
		$Panel/BuyButton.visible = false
		$Panel/EditButton.visible = true
		$Panel/DeleteButton.visible = true

func _on_BuyButton_pressed():
	if selected_listing_item != null:
		$ConfirmationDialog.visible = true
		
func _on_ConfirmationDialog_confirmed():
	MarketplaceManager.buyEquipmentFromMarket(selected_listing_item)

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
