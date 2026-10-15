## Örnek bölümün belirli noktalarından ekran görüntüsü (pencereli çalıştır):
##
##  REDMOUNT_CAPTURE_DIR=... godot --path . --resolution 1280x720 res://tests/capture_ornek.tscn
extends Node

const SHOTS := [
	["1_giris", Vector2(560, -40)], ["2_tente", Vector2(1180, -40)],
	["3_catilar", Vector2(1600, -300)], ["4_tas_set", Vector2(2750, -130)],
	["5_gizli_han", Vector2(3450, -40)], ["6_han_dami", Vector2(3450, -240)],
	["7_pazar", Vector2(4300, -40)], ["8_bufe", Vector2(5080, -40)],
	["9_iskele", Vector2(5500, -150)], ["10_bina_cati", Vector2(6150, -460)],
	["11_vinc", Vector2(6500, -460)], ["12_han_kapisi", Vector2(8450, -40)],
]


func _ready() -> void:
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	GameState.level_path_override = "res://scenes/levels/Bolum01.tscn"
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	var player: Node2D = main.get_node(^"Redmount")
	# Işınlanan oyuncu arenaları kilitlemesin.
	for a in get_tree().get_nodes_in_group(&"battle_arena"):
		a.queue_free()
	for shot in SHOTS:
		player.global_position = shot[1]
		(player as CharacterBody2D).velocity = Vector2.ZERO
		for i in 50:
			await get_tree().physics_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(folder.path_join("%s.png" % shot[0]))
	get_tree().quit()
