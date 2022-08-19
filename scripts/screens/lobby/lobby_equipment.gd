extends Control


func _ready() -> void:
	EquipmentManager.connect("equipment_equipped", self, "_on_equipment_equipped")
	NotificationManager.connect_pressed_signal(self, "_on_notification_pressed")
	if EquipmentManager.equipped["skill_caster"].size() > 0:
		update_button($WeaponEquipButton, EquipmentManager.equipped["skill_caster"][0].TEX[0])


func show_equipment_selector(type: String) -> void:
	var selector = ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_SELECTOR)
	selector.set_type(type)


func update_button(btn: ButtonEquip, tex: Texture):
	if not btn.mode:
		btn.toggle_mode()
	btn.set_tex(tex)


func _on_notification_pressed(notif_id: int) -> void:
	if notif_id == Notification.NOTIF_NO_EQUIPMENT["id"]:
		show_equipment_selector("skill_caster")


func _on_WeaponEquipButton_pressed() -> void:
	show_equipment_selector("skill_caster")


func _on_equipment_equipped(type: String, eq: Equipment) -> void:
	match type:
		EquipmentManager.TYPE_SKILL_CASTER:
			update_button($WeaponEquipButton, eq.TEX[0])
