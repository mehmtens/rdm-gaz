## Örnek bölümün hikâye sahnelerini kare kare kaydeder (pencereli çalıştır):
##
##  REDMOUNT_CAPTURE_DIR=... godot --path . --resolution 1280x720 res://tests/capture_cutscenes.tscn
extends Node

const SPOTS := [["catı", Vector2(1380, -260)], ["pazar", Vector2(3815, -40)], ["han", Vector2(8365, -40)]]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	GameState.level_path_override = "res://scenes/levels/OrnekBolum.tscn"
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	var player: Node2D = main.get_node(^"Redmount")
	# Açılış sahnesini atla, arenaları kaldır.
	for i in 30:
		await get_tree().process_frame
		if Cutscene.active != null:
			Cutscene.active._skip = true
	while Cutscene.active != null:
		await get_tree().process_frame
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	for spot in SPOTS:
		player.global_position = spot[1]
		var n := 0
		for i in 2400:
			await get_tree().process_frame
			if Cutscene.active != null:
				if i % 12 == 0:
					await RenderingServer.frame_post_draw
					get_viewport().get_texture().get_image().save_png(folder.path_join("%s_%03d.png" % [spot[0], n]))
					n += 1
				# Konuşmalar süreyle kendiliğinden ilerler.
			elif n > 0:
				break
	get_tree().quit()
