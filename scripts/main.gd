extends Node

var back : bool setget _set_back

signal go_back()

# func _ready():
# 	var s =var2str([Vector2(0,0), [Enemy.DropInfo.new(Vector2(0,0), "", "5")]])
# 	print(s)
# 	var ss = str2var(s)[1][0] as Enemy.DropInfo
# 	print(ss.direction)


func _set_back(flag : bool) -> void:
	back = flag
	$UI/Titlebar/BackButton.visible = back
	print($UI/Titlebar/BackButton.visible)

func hide_background() -> void:
	$Node2D/Background.visible = false


func show_background() -> void:
	$Node2D/Background.visible = true

func hide_titlebar() -> void:
	$UI/Titlebar.hide()

func show_titlebar() -> void:
	$UI/Titlebar.show()

func set_title(title: String) -> void:
	$UI/Titlebar/Title.text = title


func _on_BackButton_pressed():
	emit_signal("go_back")
