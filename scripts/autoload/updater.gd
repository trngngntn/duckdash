extends Node

const PTIME = 5

var ptimer: Array = []
var init_ptimer: Timer

var timer: Timer
var slow_timer: Timer
var init_count = 0

signal timeout
signal timeout_slow

signal ptimeout(seq)


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

	MatchManager.connect("match_ready", self, "init_p")
	MatchManager.connect("disconnected", self, "f_disconnect")


func init_p(_d):
	print("READY")
	for i in range(0, PTIME):
		var tm = Timer.new()
		tm.wait_time = 1.0
		tm.one_shot = false
		tm.connect("timeout", self, "emit_ptimeout", [i])
		ptimer.append(tm)
		add_child(tm)

	init_ptimer = Timer.new()
	init_ptimer.wait_time = 1.0 / PTIME
	init_ptimer.one_shot = false
	init_ptimer.connect("timeout", self, "f_init_ptimer")
	add_child(init_ptimer)
	init_ptimer.start()


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


func f_init_ptimer():
	if init_count < PTIME:
		ptimer[init_count].start()
		init_count += 1
	else:
		init_ptimer.stop()


func emit_ptimeout(seq: int):
	emit_signal("ptimeout", seq)

func f_disconnect():
	timer.stop()
	slow_timer.stop()
	if is_instance_valid(init_ptimer):
		init_ptimer.stop()
	for tm in ptimer:
		if is_instance_valid(tm):
			tm.queue_free()
