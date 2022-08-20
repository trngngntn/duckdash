class_name ItemCount extends Control

const ITEM = [
	preload("res://assets/sprites/static/ui/ui_icon_coin.png"),
	preload("res://assets/sprites/static/ui/ui_icon_soul.png")
]

enum Item { COIN = 0, SOUL = 1 }

var current_item: int = Item.COIN

var value: int setget _set_value


func _set_value(_value: int):
	value = _value
	$Value.text = str(value)


func set_item(item: int):
	current_item = item
	$Texture.texture = ITEM[item]
