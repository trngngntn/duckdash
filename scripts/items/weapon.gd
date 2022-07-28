extends Equipment
class_name Weapon

const SUB_TYPE_POWER_PUNCH = preload("res://scenes/character/skills/attack_power_punch.tscn")
const SUB_TYPE_TERROR_SLASH = preload("res://scenes/character/skills/attack_terror_slash.tscn")
const SUB_TYPE_MAGIC_BULLET = preload("res://scenes/character/skills/attack_magic_bullet.tscn")
const SUB_TYPE_ENERGY_BLADE = preload("res://scenes/character/skills/attack_energy_blade.tscn")

func _init():
    type_name = "weapon"