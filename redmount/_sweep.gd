extends Node
# Kamera sweep: bir bölümü baştan sona pan edip screenshot alır (geometri gözden geçirme).
var _lvl := 4

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://_showcase")
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	GameState.level_index = _lvl
	main._load_current_level()
	get_tree().paused = true
	var player: Node2D = main.get_node(^"Redmount")
	var cam: Camera2D = player.get_node(^"Camera2D")
	cam.position_smoothing_enabled = false
	var lvl: Node = main.get_node(^"LevelHolder").get_child(0)
	var x0: float = lvl.camera_limit_left + 300.0
	var x1: float = lvl.camera_limit_right - 300.0
	var y: float = -120.0
	var n := 12
	for i in n + 1:
		var cx: float = lerpf(x0, x1, float(i) / float(n))
		player.global_position = Vector2(cx, y)
		cam.reset_smoothing()
		cam.force_update_scroll()
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(
			"res://_showcase/sweep_l%02d_%02d_x%05.0f.png" % [_lvl + 1, i, cx])
	print("SWEEP done lvl=%d" % (_lvl + 1))
	get_tree().quit()
