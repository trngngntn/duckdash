class_name Listing

var id: int
var equipment: Equipment
var price: int setget _set_price
var seller: String

signal deleted
signal updated(new_price)


func _set_price(_price: int) -> void:
	price = _price
	emit_signal("updated", price)


func delete() -> void:
	emit_signal("deleted")


func _init(item):
	id = item["id"]
	equipment = EquipmentManager.dict2equipment(item["equipment"])
	price = item["price"]
	seller = item["user_id"]
