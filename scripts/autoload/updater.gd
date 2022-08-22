extends Node

var timer: Timer

signal timeout


func _init():
	timer = Timer.new()
	timer.wait_time = 0.25
	timer.one_shot = false

	timer.connect("timeout", self, "emit")

	add_child(timer)


func start():
	# print("[LOG][UPD]Timer start")
	if MatchManager.is_network_server():
		timer.start()


func stop():
	# print("[LOG][UPD]Timer stop")
	timer.stop()


func emit():
	# print("[LOG][UPD]Timeout")
	emit_signal("timeout")
