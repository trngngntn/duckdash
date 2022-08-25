extends Control

const TITLE = "Marketplace"
const item_res = preload("res://scenes/items/listing_item.tscn")
var font = preload("res://resources/font/ui_font_small.tres")
var selected_listing_item: MarketListingItem

func _ready():
	MarketplaceManager.get_all_listing_item(false)
	var listing_items = MarketplaceManager.getMarketListingItem()
	update_item(listing_items)

func update_item(items: Array) -> void:
	for equipment in items:
		add_item(equipment)

func add_item(item: MarketListingItem) -> void:
	var new_item = item_res.instance()
	new_item.setProperties(item)
	new_item.connect("listing_item_selected", self, "_on_listing_item_selected")
	$TabContainer/Market/ScrollContainer/GridContainer.add_child(new_item)

func _on_listing_item_selected(item: MarketListingItem):
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
		
	$Panel/ScrollContainer/VBoxContainer/BuyButton.visible = true

func _on_BuyButton_pressed():
	if selected_listing_item != null:
		$ConfirmationDialog.visible = true
		
func _on_ConfirmationDialog_confirmed():
	MarketplaceManager.buyEquipmentFromMarket(selected_listing_item)
