extends Node

var go_back : bool setget _set_go_back

signal go_back()

func _set_go_back(flag : bool) -> void:
	go_back = flag
	if go_back:
		$UI/Titlebar/BackButton.visible = true

func hide_titlebar() -> void:
	$UI/Titlebar.visible = false

func set_title(title: String) -> void:
	$UI/Titlebar/Title.text = title


func _on_BackButton_pressed():
	emit_signal("go_back")
