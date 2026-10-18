## Kayma tekmesi: koşarken çömel -> düşman havaya kalkar mı, oyuncu kayar mı?
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
	var p: CharacterBody2D = main.get_node(^"Redmount")
	p.global_position = Vector2(7100, -20)
	var e: Node2D = load("res://scenes/enemies/StreetThug.tscn").instantiate()
	e.position = Vector2(7400, 0)
	lv.add_child(e)
	for i in 10:
		await get_tree().physics_frame
	var hp0: int = e.get_health()
	Input.action_press(&"move_right")
	Input.action_press(&"run")
	for i in 30:
		get_tree().paused = false
		await get_tree().physics_frame
	print("vx before slide=%.0f state=%s" % [p.velocity.x, p.get("_state")])
	var x0 := p.global_position.x
	Input.action_press(&"crouch")
	var shot := false
	for i in 40:
		get_tree().paused = false
		await get_tree().physics_frame
		if i < 12: print("f%d st=%s vx=%.0f sp=%s" % [i, p.get("_state"), p.velocity.x, p.get("_special_move")])
		if i == 8 and not shot:
			shot = true
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(OS.get_environment("REDMOUNT_CAPTURE_DIR").path_join("slide.png"))
	print("SLIDE moved=%.0f enemy hp %d -> %d" % [p.global_position.x - x0, hp0, e.get_health()])
	get_tree().quit()
