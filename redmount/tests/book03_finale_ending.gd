## Yalnız epilog/sonuç ekranı için görsel fixture; tam rota testi ayrı dosyada.
extends SceneTree


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	root.get_node("GameState").level_index = 35
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._player.global_position = Vector2(270400, -40)
	main._player.get_node("Camera2D").reset_smoothing()
	main._player.get_node("Camera2D").force_update_scroll()
	await process_frame
	await process_frame
	var final = main._level
	final.relays_cut = 3
	final.boss_defeated = true
	main._on_goal_reached()
	await process_frame
	main._dialogue._advance()
	await _capture("epilog.png")
	while main._dialogue.is_active():
		main._dialogue._advance()
		await process_frame
	assert(final.ending_seen and main._finished, "Epilog sonuç ekranına bağlanmalı.")
	await create_timer(1.0, true).timeout
	await _capture("sonuc.png")
	paused = false
	main.queue_free()
	await process_frame
	await process_frame
	quit(0)


func _capture(filename: String) -> void:
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	if folder.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(filename))
