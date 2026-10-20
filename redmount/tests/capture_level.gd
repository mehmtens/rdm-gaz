## Herhangi bir bölümün verilen noktalarından ekran görüntüsü (pencereli çalıştır).
## Hikâye sahneleri atlanır, arenalar kaldırılır (ışınlanan oyuncu kilitlemesin).
##
##  REDMOUNT_PROBE_LEVEL=1 REDMOUNT_SHOTS="giris:500:-40;cati:1600:-300" \
##  REDMOUNT_CAPTURE_DIR=... godot --path . --resolution 1280x720 res://tests/capture_level.tscn
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	GameState.level_index = OS.get_environment("REDMOUNT_PROBE_LEVEL").to_int()
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	GameState.level_index = OS.get_environment("REDMOUNT_PROBE_LEVEL").to_int()
	main._load_current_level()
	await get_tree().process_frame
	var player: Node2D = main.get_node(^"Redmount")
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	for spec in OS.get_environment("REDMOUNT_SHOTS").split(";", false):
		var f := spec.split(":")
		player.global_position = Vector2(f[1].to_float(), f[2].to_float())
		(player as CharacterBody2D).velocity = Vector2.ZERO
		for i in 50:
			await get_tree().process_frame
			if Cutscene.active != null:
				Cutscene.active._skip = true
		while Cutscene.active != null:
			await get_tree().process_frame
		player.global_position = Vector2(f[1].to_float(), f[2].to_float())
		var extra := OS.get_environment("REDMOUNT_SHOT_WAIT").to_int()
		for i in 30 + extra:
			await get_tree().physics_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(folder.path_join("%s.png" % f[0]))
	get_tree().quit()
