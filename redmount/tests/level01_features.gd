extends SceneTree

## Bölüm 1 özellik testi: öğretici ipuçları, piksel tabela + mekân pankartı,
## dağılan bulut platform, dokununca açılan büfe ve kaldırılmış kırılabilir kaplar.
## REDMOUNT_CAPTURE_DIR verilirse (pencereli çalıştırmada) ekran görüntüsü de alır.


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var state := root.get_node(^"GameState")
	state.level_index = 0
	state.story_scenes = false
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await _frames(20)
	var player: CharacterBody2D = main._player
	var level: Node = main._level

	assert(get_nodes_in_group(&"hint").size() >= 10, "Bölüm 1 öğretici ipuçları eksik")
	for node in _all(level):
		assert(not node is BreakableProp, "Kırılabilir kaplar kaldırılmış olmalı")
	assert(not main._hud.get_node(^"StageLabel").visible, "Bölüm numarası gizli olmalı")
	await _frames(40)
	await _capture("l1-start")

	# --- Mekân tabelası + pankart ---
	player.global_position = Vector2(3150, -40)
	await _frames(50)
	assert(main._hud._place != null and main._hud._place.visible, "Mekân pankartı görünmeli")
	await _capture("l1-place")

	# --- Bulut: üstünde durunca dağılır, sonra geri gelir ---
	var cloud: Node2D = null
	for node in _all(level):
		if node is StaticBody2D and node.get(&"style") == "cloud":
			cloud = node
			break
	assert(cloud != null, "Bölüm 1'de bulut platform bulunmalı")
	player.velocity = Vector2.ZERO
	player.global_position = cloud.global_position + Vector2(0, -40)
	await _frames(30)
	assert(player.is_on_floor(), "Oyuncu bulutun üstünde durabilmeli")
	var stand_y := player.global_position.y
	await _capture("l1-cloud")
	await create_timer(0.75, false).timeout
	await _capture("l1-cloud-fading")
	await create_timer(0.7, false).timeout
	assert(cloud.get_node(^"CollisionShape2D").disabled, "Bulut yaklaşık 1 sn sonra dağılmalı")
	assert(player.global_position.y > stand_y + 20.0, "Bulut dağılınca oyuncu düşmeli")
	await create_timer(3.0, false).timeout
	assert(not cloud.get_node(^"CollisionShape2D").disabled, "Bulut geri gelmeli")

	# --- Büfe: dokununca panel açılır, karta dokununca satın alınır ---
	var shop: LevelShop = null
	for node in _all(level):
		if node is LevelShop:
			shop = node
			break
	assert(shop != null)
	player.velocity = Vector2.ZERO
	player.global_position = shop.global_position + Vector2(60, -40)
	await _frames(40)
	assert(shop._near, "Oyuncu büfenin yanında sayılmalı")
	await _capture("l1-shop-near")
	state.coins = 40
	var tap := InputEventScreenTouch.new()
	tap.pressed = true
	tap.position = shop.get_canvas_transform() * shop.to_global(Vector2(100, -150))
	Input.parse_input_event(tap)
	await _frames(3)
	assert(shop.is_open() and paused, "Büfeye dokununca panel açılmalı ve oyun durmalı")
	await _frames(10)
	await _capture("l1-shop-panel")
	assert(shop.buy("can"), "Yeterli coin varken satın alınabilmeli")
	assert(state.coins == 25)
	state.coins = 0
	assert(not shop.buy("can"), "Coin yetmeyince satın alınmamalı")
	await create_timer(0.3).timeout
	shop.close()
	assert(not shop.is_open() and not paused, "Panel kapanınca oyun devam etmeli")

	main.queue_free()
	await process_frame
	print("LEVEL01 FEATURES OK")
	quit(0)


func _all(node: Node) -> Array:
	var out: Array = [node]
	for child in node.get_children():
		out.append_array(_all(child))
	return out


func _frames(count: int) -> void:
	for i in count:
		await physics_frame


func _capture(name: String) -> void:
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	if folder.is_empty():
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(name + ".png"))
