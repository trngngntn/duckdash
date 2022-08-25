extends Node

onready var self_instance = self

var listing_items = []

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


func get_all_listing_item(of_this_user: bool):
	if Conn.nkm_session == null or Conn.nkm_session.is_expired():
		Conn.renew_session()
		yield(Conn, "session_changed")
		if Conn.nkm_session == null:
			NotificationManager.show_custom_notification("Error", "Session error!")
			ScreenManager.change_screen(ScreenManager.SCREEN_LOGIN, false)
			return

	var payload = {"ofCurrentUser": of_this_user}
	var response: NakamaAPI.ApiRpc = yield(
		Conn.nkm_client.rpc_async(Conn.nkm_session, "get_listing_item", JSON.print(payload)),
		"completed"
	)
	if response.is_exception():
		NotificationManager.show_custom_notification("Error", response.get_exception().message)
		return null

	var result = JSON.parse(response.payload).result
	for item in result:
		listing_items.append(MarketListingItem.new(item))

func getMarketListingItem():
	return listing_items

func buyEquipmentFromMarket(listing_item: MarketListingItem):
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

# CALLBACKS
func _on_session_created(_d) -> void:
	get_all_listing_item(false)

func _on_session_changed(_d) -> void:
	listing_items = []
