extends "res://_autoplay.gd"


func _ready() -> void:
	# Simülasyon adımı 1/60 sn kalır; yalnız testin duvar saati kısalır.
	var speed := clampf(OS.get_environment("REDMOUNT_TEST_SPEED").to_float(), 1.0, 8.0)
	Engine.physics_ticks_per_second = int(60 * speed)
	Engine.max_physics_steps_per_frame = int(8 * speed)
	Engine.time_scale = speed
	Combat.hitstop(0.02)
	while Combat._hitstop_running:
		await get_tree().process_frame
	assert(is_equal_approx(Engine.time_scale, speed), "Hitstop önceki oyun hızını geri getirmeli.")
	Save.purchased = []
	seed(20260929)
	_time_limit = 1500.0
	OS.set_environment("REDMOUNT_PROBE_LEVEL", "35")
	await super._ready()
	assert(not _main._level._final_goal.monitoring, "Final kapısı boss öncesi kapalı olmalı.")


func _finish_level(msg: String) -> void:
	var final = _main._level
	var checks := {
		"Bölüm baştan sona tamamlandı": msg.begins_with("CLEARED") and _max_x > 270000,
		"18–23 dakika hedefi": _run_t >= 1080 and _run_t <= 1380,
		"Üç yayın hattı kesildi": final.relays_cut == 3,
		"Boss yenildi": final.boss_defeated,
		"Üç boss evresi oynandı": final.boss_phases_seen == [0, 1, 2],
		"Boss her evrede saldırdı": final.boss_attack_phases == [0, 1, 2],
		"Kapanış görüldü": final.ending_seen,
		"Sonuç kaydedildi": Save.best_score(35) > 0,
	}
	var failed := false
	for description in checks:
		print("FINAL CHECK: %s — %s" % [description, "PASS" if checks[description] else "FAIL"])
		failed = failed or not checks[description]
	print("FINAL RUN: %.1fs; respawns=%d; phases=%s" % [_run_t, _respawns, final.boss_phases_seen])
	if failed:
		push_error("Kitap 3 final doğrulaması başarısız: %s" % msg)
	print("PROBE Bölüm 36: %s" % msg)
	set_physics_process(false)
	for action in [&"move_right", &"move_left", &"run", &"attack", &"jump", &"dash"]:
		Input.action_release(action)
	get_tree().paused = false
	_main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	Engine.time_scale = 1.0
	get_tree().quit(1 if failed else 0)
