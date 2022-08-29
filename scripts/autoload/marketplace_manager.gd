extends Node

var listing_items: Dictionary = {"listing": {}, "self_listing": {}}

signal listing_updated
signal self_listing_updated

signal listing_added(type, new_listing)
signal listing_deleted(type, id)


func _init() -> void:
	Conn.connect("session_connected", self, "_on_session_created")
	Conn.connect("notif_listing_updated", self, "_on_listing_updated")


func fetch_listings():
	listing_items = {"listing": {}, "self_listing": {}}

	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "get_listing_item", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null

	var result = JSON.parse(response.payload).result
	for item in result:
		if item.my_listing:
			listing_items["self_listing"][item["id"]] = Listing.new(item)
		else:
			listing_items["listing"][item["id"]] = Listing.new(item)


func get_listings():
	return listing_items


func list_equipment(equipment: Equipment, price: int) -> void:
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"equipmentHash": equipment.raw, "price": price}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "list_an_item_to_market", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null
	equipment.list()
	NotificationManager.show_custom_notification("Success", "Listing item to marketplace success")


func buy_equipment(listing_item: Listing):
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"listingId": listing_item.id}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "buy_item_from_market", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null
	var equipment = listing_item.equipment
	EquipmentManager.equipment_list[equipment.type_name].append(equipment)
	NotificationManager.show_custom_notification("Success", "Buy item success")


func edit_listing(listing_item: Listing, price: int):
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"listingId": listing_item.id, "price": price}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "update_a_listing", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null

	NotificationManager.show_custom_notification("Success", "Edit listing item success")


func delete_listing(listing_item: Listing):
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"listingId": listing_item.id}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "delete_a_listing", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null
	var equipment = listing_item.equipment
	EquipmentManager.equipment_list[equipment.type_name].append(equipment)
	NotificationManager.show_custom_notification("Success", "Delete listing item success")


# CALLBACKS
func _on_session_created(_d) -> void:
	fetch_listings()


func _on_listing_updated(content: String) -> void:
	print("[LOG][MARKET_MAN]Listing updated notif from server")
	var listing = JSON.parse(content).result
	## new listing addeds
	if listing.has("user_id"):
		var new_listing = Listing.new(listing)
		if Conn.nkm_session.user_id == listing["user_id"]:
			listing_items["self_listing"][listing["id"]] = new_listing
			print("[LOG][MARKET_MAN]Self isting added")
			emit_signal("listing_added", "self_listing", new_listing)
		else:
			listing_items["listing"][listing["id"]] = new_listing
			print("[LOG][MARKET_MAN]Listing added")
			emit_signal("listing_added", "listing", new_listing)

	## listing edited
	else:
		for key in listing_items.keys():
			if listing_items[key].has(listing["id"]):
				if listing["price"] == -1:
					listing_items[key][listing["id"]].delete()
					listing_items[key].erase(listing["id"])
					print("[LOG][MARKET_MAN]Deleted " + key)
					emit_signal("listing_deleted", key, listing["id"])
				else:
					listing_items[key][listing["id"]].price = listing["price"]
					print("[LOG][MARKET_MAN]Update price " + key)
				emit_signal(key + "_updated")
