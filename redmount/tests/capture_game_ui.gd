## Oyun içi arayüz görüntüleri: oynanış HUD'u, duraklat menüsü, bölüm sonu ekranı.
##
##  REDMOUNT_CAPTURE_DIR=... godot --path . --resolution 1280x720 res://tests/capture_game_ui.tscn
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
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
	var player: Node2D = main.get_node(^"Redmount")
	player.global_position = Vector2(900, -40)
	for i in 60:
		await get_tree().process_frame
	await _shot(folder, "a_hud")
	main.get("_pause_menu").open()
	for i in 30:
		await get_tree().process_frame
	await _shot(folder, "b_pause")
	main.get("_pause_menu").close()
	main.get("_hud").show_results(42, 11, 14, 95.0, 6420, "BÖLÜM 1 TAMAMLANDI", "A", 3)
	for i in 240:
		await get_tree().process_frame
	await _shot(folder, "c_results")
	get_tree().quit()


func _shot(folder: String, name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(folder.path_join(name + ".png"))
