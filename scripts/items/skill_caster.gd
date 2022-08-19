extends Equipment
class_name SkillCaster

const TEX = [preload("res://assets/sprites/static/item/weapon.png")]

const SUB_TYPE = {
	"POWER_PUNCH":
	{
		"name": "Power Punch",
		"res": preload("res://scenes/character/skills/skill_attack_power_punch.tscn"),
	},
	"TERROR_SLASH":
	{
		"name": "Terror Slash",
		"res": preload("res://scenes/character/skills/skill_attack_terror_slash.tscn"),
	},
	"MAGIC_BULLET":
	{
		"name": "Magic Bullet",
		"res": preload("res://scenes/character/skills/skill_attack_magic_bullet.tscn"),
	},
	"ENERGY_BLADE":
	{
		"name": "Energy Blade",
		"res": preload("res://scenes/character/skills/skill_attack_energy_blade.tscn"),
	},
}


func _init(eq):
	raw = eq.raw
	type_name = "skill_caster"
	sub_type = eq.sub_type
	tier = eq.tier
	stat = eq.stat
