## Kalkanlı + bombacı denetimi: önden/arkadan vuruş, ağır darbe, bomba atışı.
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.level_index = 12
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
	var lv: Node = main.get_node(^"LevelHolder").get_child(0)
	var p: Node2D = main.get_node(^"Redmount")
	p.global_position = Vector2(8500, -20)
	var sg: Node2D = load("res://scenes/enemies/ShieldGuard.tscn").instantiate()
	sg.position = Vector2(8620, 0)
	lv.add_child(sg)
	var bm: Node2D = load("res://scenes/enemies/Bomber.tscn").instantiate()
	bm.position = Vector2(8900, 0)
	lv.add_child(bm)
	for i in 40:
		if Cutscene.active != null:
			Cutscene.active._skip = true
		get_tree().paused = false
		await get_tree().physics_frame
	var h0: int = sg.get_health()
	sg.apply_hit(6, Vector2(1, 0), 120.0)   # oyuncu solda, sağa vuruyor = önden
	var h1: int = sg.get_health()
	sg.apply_hit(6, Vector2(-1, 0), 120.0)  # arkadan
	var h2: int = sg.get_health()
	sg.apply_hit(18, Vector2(1, 0), 380.0)  # önden ağır
	var h3: int = sg.get_health()
	print("SHIELD front %d->%d back ->%d heavy ->%d" % [h0, h1, h2, h3])
	var thrown := false
	for i in 300:
		if Cutscene.active != null:
			Cutscene.active._skip = true
		get_tree().paused = false
		await get_tree().physics_frame
		if not thrown and bm.get("_aiming"):
			thrown = true
			for k in 10:
				await get_tree().physics_frame
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(OS.get_environment("REDMOUNT_CAPTURE_DIR").path_join("bomb.png"))
	print("BOMB thrown=%s player_hp=%d" % [thrown, p.get_health()])
	get_tree().quit()
