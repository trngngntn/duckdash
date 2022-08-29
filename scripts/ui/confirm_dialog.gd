class_name ConfirmDialog extends Control

export var message: String setget _set_message

signal confirmed
signal rejected


func _set_message(_message: String) -> void:
	message = _message
	$NinePatchRect/VBoxContainer/Message.text = message


func _on_CancelButton_pressed():
	emit_signal("rejected")
	hide()


func _on_OKButton_pressed():
	emit_signal("confirmed")
	hide()
