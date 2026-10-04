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
	var scroll := menu.get_node(^"Root/LevelsScroll") as ScrollContainer
	var buttons := menu.get_node(^"Root/LevelsScroll/Levels") as HBoxContainer
	assert(buttons.get_child_count() == GAME_STATE_SCRIPT.LEVELS.size(), "Menüde bölüm düğmesi eksik.")
	scroll.scroll_horizontal = 99999
	await process_frame
	assert(scroll.scroll_horizontal > 0, "Son bölüm düğmeleri yatay kaydırma ile erişilebilir olmalı.")
	var menu_root := menu.get_node(^"Root") as Control
	assert(menu_root.position.y >= 0 and menu_root.position.y + menu_root.size.y <= root.get_viewport().get_visible_rect().size.y,
		"Menü dikey olarak ekran dışına taşmamalı.")
	menu.queue_free()
	quit(0)
