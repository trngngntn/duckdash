extends Node

var timer: Timer
var slow_timer: Timer

signal timeout
signal timeout_slow


func _init():
	timer = Timer.new()
	timer.wait_time = 0.25
	timer.one_shot = false
	timer.connect("timeout", self, "emit")
	add_child(timer)

	slow_timer = Timer.new()
	slow_timer.wait_time = 1
	slow_timer.one_shot = false
	slow_timer.connect("timeout", self, "emit_slow")
	add_child(slow_timer)


func start():
	# print("[LOG][UPD]Timer start")
	if MatchManager.is_network_server():
		timer.start()
		slow_timer.start()


func stop():
	# print("[LOG][UPD]Timer stop")
	timer.stop()


func emit():
	# print("[LOG][UPD]Timeout")
	emit_signal("timeout")


func emit_slow():
	# print("[LOG][UPD]Timeout")
	emit_signal("timeout_slow")
