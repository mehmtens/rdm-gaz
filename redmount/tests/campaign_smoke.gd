extends SceneTree

const GAME_STATE_SCRIPT := preload("res://scripts/systems/game_state.gd")


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	assert(GAME_STATE_SCRIPT.LEVELS.size() == 36, "Kitap 3 finali kampanyaya eklenmeli.")
	for path in GAME_STATE_SCRIPT.LEVELS:
		var packed := load(path) as PackedScene
		assert(packed != null, "%s yüklenemedi." % path)
		var level := packed.instantiate()
		root.add_child(level)
		await process_frame
		assert(level is Level, "%s Level tabanını kullanmıyor." % path)
		assert(level.get_node_or_null(^"PlayerSpawn") != null, "%s PlayerSpawn içermiyor." % path)
		print("SMOKE OK: %s" % path)
		level.queue_free()
		await process_frame
	var menu := (load("res://scenes/MainMenu.tscn") as PackedScene).instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu._show(menu._levels)
	assert(menu._tabs.size() == 3, "Kitap sekmeleri eksik.")
	for book in 3:
		menu._select_book(book)
		await process_frame
		assert(menu._grid.get_child_count() == 12, "Kitap %d bölüm kartları eksik." % (book + 1))
		assert(menu._book_title.text.begins_with("KİTAP %d" % (book + 1)), "Kitap sekmesi değişmedi.")
	menu.queue_free()
	quit(0)
