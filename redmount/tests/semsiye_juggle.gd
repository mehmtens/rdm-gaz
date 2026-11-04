## Şemsiye sonsuz kilit koruması (tur 155): gerçek girdiyle şemsiyeyi seri
## basınca devrik düşman (havada ya da iniş karesinde) yeniden kaldırılmamalı;
## düşman her kaldırıştan sonra kalkıp yeniden harekete geçebilmeli.
##
##  godot --headless --path . --fixed-fps 60 res://tests/semsiye_juggle.tscn
extends Node

const UMBRELLA := preload("res://resources/weapons/semsiye.tres")

var _fails := 0


func _ready() -> void:
	Save._path = "user://semsiye_juggle_test.cfg"
	Save.wipe()
	for per in [2, 6]:
		await _mash(per)
	Save.wipe()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://semsiye_juggle_test.cfg"))
	print("SEMSIYE JUGGLE: %s" % ("PASS" if _fails == 0 else "FAIL (%d)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_fails += 1
		push_error("BASARISIZ: " + what)


## Her `per` karede bir saldırı basar, düşmana yakın kalır; 10 sn ölçer.
func _mash(per: int) -> void:
	GameState.level_index = 0
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	add_child(main)
	for node in main._level.get_children():
		if node is Cutscene:
			node._started = true
	for i in 30:
		await get_tree().physics_frame
	var player = main._player
	var thug: Node2D = (load("res://scenes/enemies/StreetThug.tscn") as PackedScene).instantiate()
	main._level.add_child(thug)
	thug.global_position = player.global_position + Vector2(70, -10)
	thug._health = 100000
	for i in 30:
		await get_tree().physics_frame
	player.equip_weapon(UMBRELLA)
	player._facing = 1
	var hp0: int = thug._health
	var air_frames := 0
	var max_air := 0
	var launches := 0
	var down_relaunch := 0
	var recoveries := 0
	var prev_vy := 0.0
	var was_down := false
	for f in 600:
		if f % per == 0:
			Input.action_press(&"attack")
		elif f % per == 1:
			Input.action_release(&"attack")
		var dx: float = thug.global_position.x - player.global_position.x
		Input.action_release(&"move_right")
		Input.action_release(&"move_left")
		if absf(dx) > 75.0:
			Input.action_press(&"move_right" if dx > 0.0 else &"move_left")
		await get_tree().physics_frame
		if thug.velocity.y < -150.0 and prev_vy >= -150.0:
			launches += 1
			if was_down:
				down_relaunch += 1
		var down: bool = thug.is_knocked_down()
		if was_down and not down:
			recoveries += 1
		was_down = down
		prev_vy = thug.velocity.y
		air_frames = 0 if thug.is_on_floor() else air_frames + 1
		max_air = maxi(max_air, air_frames)
	for a in [&"attack", &"move_right", &"move_left"]:
		Input.action_release(a)
	print("  her %d karede: kaldırış=%d devrikken yeniden=%d kalkış=%d en uzun hava=%d kare hasar=%d"
		% [per, launches, down_relaunch, recoveries, max_air, hp0 - thug._health])
	_check(launches >= 3 and hp0 - thug._health > 0, "şemsiye isabet edip kaldırmalı (%d)" % launches)
	_check(down_relaunch == 0, "devrik düşman yeniden kaldırılmamalı (%d)" % down_relaunch)
	_check(recoveries >= launches - 1, "düşman her kaldırıştan sonra kalkmalı (%d/%d)" % [recoveries, launches])
	main.queue_free()
	await get_tree().process_frame
