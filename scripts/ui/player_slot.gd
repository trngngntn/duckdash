extends MarginContainer

onready var _player_name = $PanelContainer/MarginContainer/HSplit/PlayerName
onready var _status = $PanelContainer/MarginContainer/HSplit/Status

func _ready():
	_player_name.text = name
	pass

func hide_status() -> void:
	_status.visible = false;

func set_status(status : String) -> void:
	_status.visible = true;
	_status.text = status

func loading() -> void:
	$PanelContainer.modulate.a = 0
	$LoadingDots.visible = true
	$LoadingDots.play()

func stop_loading() -> void:
	$PanelContainer.modulate.a = 1
	$LoadingDots.visible = false
	$LoadingDots.stop()
