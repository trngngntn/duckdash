extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	NotificationManager.connect_pressed_signal(self, "_on_notification_pressed")


func show_equipment_selector(type: String):
	var selector = ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_SELECTOR)
	selector.set_type(type)



func _on_notification_pressed(notif_id: int):
	if notif_id == Notification.NOTIF_NO_EQUIPMENT["id"]:
		show_equipment_selector("skill_caster")


func _on_WeaponEquipButton_pressed():
	show_equipment_selector("skill_caster")
