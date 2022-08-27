extends Control

const EquipButton = preload("res://scenes/ui/button_equip.tscn")


func _ready() -> void:
	EquipmentManager.connect("equipment_equipped", self, "_on_equipment_equipped")
	NotificationManager.connect_pressed_signal(self, "_on_notification_pressed")
	if EquipmentManager.equipped[EquipmentManager.TYPE_SKILL_CASTER].size() > 0:
		update_button(
			$WeaponEquipButton,
			EquipmentManager.equipped[EquipmentManager.TYPE_SKILL_CASTER][0].TEX[0]
		)

	var enhancer_count = EquipmentManager.equipped[EquipmentManager.TYPE_ENHANCER].size()
	if enhancer_count > 0:
		for i in range(0, enhancer_count):
			add_enhancer_equip_button()
			update_button(
				$VBoxContainer.get_child(i),
				EquipmentManager.equipped[EquipmentManager.TYPE_ENHANCER][i].TEX[0]
			)
	if enhancer_count < 3:
		add_enhancer_equip_button()


func add_enhancer_equip_button():
	var button = EquipButton.instance()
	button.connect(
		"pressed", self, "_on_EnhancerEquipButton_pressed", [$VBoxContainer.get_child_count()]
	)
	$VBoxContainer.add_child(button)


func show_equipment_selector(type: String, pos: int = 0) -> void:
	var selector = ScreenManager.show_screen_dialog(ScreenManager.SCREEN_EQUIPMENT_SELECTOR)
	selector.set_type(type)
	selector.set_pos(pos)


func update_button(btn: ButtonEquip, tex: Texture):
	if not btn.mode:
		btn.toggle_mode()
	btn.set_tex(tex)


func _on_notification_pressed() -> void:
	if NotificationManager.current_id == Notification.NOTIF_NO_EQUIPMENT["id"]:
		show_equipment_selector("skill_caster")
		NotificationManager.hide_notification()


func _on_WeaponEquipButton_pressed() -> void:
	show_equipment_selector(EquipmentManager.TYPE_SKILL_CASTER)


func _on_EnhancerEquipButton_pressed(pos: int) -> void:
	show_equipment_selector(EquipmentManager.TYPE_ENHANCER, pos)


func _on_equipment_equipped(type: String, eq: Equipment, pos: int) -> void:
	match type:
		EquipmentManager.TYPE_SKILL_CASTER:
			update_button($WeaponEquipButton, eq.TEX[0])
		EquipmentManager.TYPE_ENHANCER:
			update_button(
				$VBoxContainer.get_child(pos),
				EquipmentManager.equipped[EquipmentManager.TYPE_ENHANCER][pos].TEX[0]
			)
			print("Updating enehehed")
			var enhancer_count = EquipmentManager.equipped[EquipmentManager.TYPE_ENHANCER].size()
			if enhancer_count < 3 && $VBoxContainer.get_child_count() == enhancer_count:
				add_enhancer_equip_button()
