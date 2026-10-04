extends Node
# İç mekân tablosu için: SWEEP_LVLS (virgüllü 0 tabanlı indeks) bölümlerini 1500 px
# aralıkla gezer, 320x180 görüntü kaydeder. Bkz. tools/gen_parkour_interiors.py.
func _ready() -> void:
	var out := OS.get_environment("SWEEP_OUT")
	var step := 1500.0
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	for lvl_i in OS.get_environment("SWEEP_LVLS").split(","):
		var li := int(lvl_i)
		GameState.level_index = li
		main._load_current_level()
		await get_tree().process_frame
		await get_tree().physics_frame
		var player: Node2D = main.get_node(^"Redmount")
		player.process_mode = Node.PROCESS_MODE_DISABLED
		var cam: Camera2D = player.get_node(^"Camera2D")
		cam.position_smoothing_enabled = false
		var lvl: Node = main.get_node(^"LevelHolder").get_child(0)
		for e in get_tree().get_nodes_in_group(&"enemy_ai"):
			e.process_mode = Node.PROCESS_MODE_DISABLED
		var x := 0.0
		while x < lvl.camera_limit_right:
			player.global_position = Vector2(x, -4.0)
			cam.reset_smoothing()
			cam.force_update_scroll()
			for k in 3:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			img.resize(320, 180)
			img.save_png(out.path_join("c%02d_%06d.png" % [li + 1, int(x)]))
			x += step
		print("CLS done ", li + 1)
	get_tree().quit()
