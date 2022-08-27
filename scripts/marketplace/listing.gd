class_name Listing

var id: int 
var equipment: Equipment
var price: int 
var seller: String 

func _init(item):
	id = item["id"]
	equipment = EquipmentManager.dict2equipment(item["equipment"])
	price = item["price"]
	seller = item["user_id"]
