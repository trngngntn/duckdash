extends Equipment
class_name Enhancer

const TEX = [preload("res://assets/sprites/static/item/enhancer.png")]

func _init(eq):
	raw = eq.raw
	type_name = "enhancer"
	tier = eq.tier
	stat = eq.stat
