extends Control
class_name MarketListingItem

var id: int 
var item_raw: String 
var price: int 
var seller: String 

func _init(item):
	id = item["id"]
	item_raw = item["equipment_hash"]
	price = item["price"]
	seller = item["user_id"]
