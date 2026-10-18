## Patlayıcı varil testi: iki varil + düşman; ilk varile vur, zincir + hasar ölç.
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.level_index = 0
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	main._load_current_level()
	for i in 60:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		await get_tree().process_frame
	get_tree().paused = false
	var lv: Node = main.get_node(^"LevelHolder").get_child(0)
	var player: Node2D = main.get_node(^"Redmount")
	player.global_position = Vector2(7100, -40)
	var a := BreakableProp.new()
	a.kind = "patlayici"
	a.position = Vector2(7400, 0)
	lv.add_child(a)
	var b := BreakableProp.new()
	b.kind = "patlayici"
	b.position = Vector2(7550, 0)
	lv.add_child(b)
	var e: Node2D = load("res://scenes/enemies/StreetThug.tscn").instantiate()
	e.position = Vector2(7480, 0)
	lv.add_child(e)
	for i in 20:
		await get_tree().physics_frame
	var hp0: int = e.get_health()
	a.apply_hit(1, Vector2.RIGHT, 0.0)
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("REDMOUNT_CAPTURE_DIR").path_join("boom.png"))
	for i in 120:
		if Cutscene.active != null:
			Cutscene.active._skip = true
		get_tree().paused = false
		await get_tree().process_frame
	print("ts=%s paused=%s " % [Engine.time_scale, get_tree().paused], "BARREL enemy hp %d -> %d, chain_b_broken=%s" % [hp0, e.get_health() if is_instance_valid(e) else -1, not is_instance_valid(b)])
	get_tree().quit()
