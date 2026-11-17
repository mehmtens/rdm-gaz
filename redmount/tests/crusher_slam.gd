## Pres iniş sesi (tur 270): yakın oyuncuda her inişte bir kez çalar; uzakta susar.
extends Node

var _fails := 0


func _ready() -> void:
	_check(not is_nan(Crusher.slam_volume_db(100.0)), "yakında duyulur")
	_check(Crusher.slam_volume_db(800.0) < Crusher.slam_volume_db(300.0), "uzaklaştıkça kısılır")
	_check(is_nan(Crusher.slam_volume_db(1200.0)), "çok uzakta susar")
	var player := Node2D.new()
	player.add_to_group(&"player")
	add_child(player)
	var c := Crusher.new()
	c.period = 1.0
	c.telegraph = 0.3
	c.position = Vector2(0, -200)
	add_child(c)
	player.global_position = Vector2(0, 0)
	var n := 0
	var t := 0.0
	while t < 2.05:
		Sfx.last_played = &""
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
		if Sfx.last_played == &"heavy_hit":
			n += 1
	_check(n == 2, "2 sn'de iki iniş sesi (%d)" % n)
	player.global_position = Vector2(5000, 0)
	n = 0
	t = 0.0
	while t < 1.05:
		Sfx.last_played = &""
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
		if Sfx.last_played == &"heavy_hit":
			n += 1
	_check(n == 0, "uzaktaki pres sessiz")
	print("CRUSHER SLAM: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)
