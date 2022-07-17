extends Control

func play() -> void:
	$Control/AnimatedSprite.play("load")

func stop() -> void:
	$Control/AnimatedSprite.stop()