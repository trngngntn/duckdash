extends MarginContainer

onready var _player_name = $PanelContainer/MarginContainer/HSplit/PlayerName
onready var _status = $PanelContainer/MarginContainer/HSplit/Status

func set_player_name(name : String) -> void:
    _player_name.text = name

func set_status(status : String) -> void:
    _status.text = status