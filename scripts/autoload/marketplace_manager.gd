extends Node

onready var self_instance = self

signal update_marketplace

var listing_items: Dictionary = {
	"market": [],
	"listing": []	
}

func _init() -> void:
	var _d := Conn.connect("session_connected", self, "_on_session_created")
	_d = Conn.connect("session_changed", self, "_on_session_changed")

func list_equipment_to_market(equipment: Equipment, price: int) -> void:
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

	NotificationManager.show_custom_notification("Success", "Listing item to marketplace success")
	reload_marketplace()


func fetch_listings():
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
			listing_items["listing"].append(Listing.new(item))
		else:
			listing_items["market"].append(Listing.new(item))

func get_listings():
	return listing_items

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

	NotificationManager.show_custom_notification("Success", "Buy item success")
	EquipmentManager.reload_inventory()
	reload_marketplace()
	WalletManager.fetch_wallet(Conn.nkm_session)

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
	reload_marketplace()
	emit_signal("update_marketplace")

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

	NotificationManager.show_custom_notification("Success", "Delete listing item success")

# CALLBACKS
func _on_session_created(_d) -> void:
	fetch_listings()

func _on_session_changed(_d) -> void:
	listing_items = {
		"market": [],
		"listing": []
	}

func reload_marketplace():
	listing_items = {
		"market": [],
		"listing": []
	}
	fetch_listings()
