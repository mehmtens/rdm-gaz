## Arayüz sahnelerinin ekran görüntüsü (pencereli çalıştır).
##
##  REDMOUNT_UI="res://scenes/MainMenu.tscn:menu;res://scenes/Shop.tscn:dukkan" \
##  REDMOUNT_CAPTURE_DIR=... godot --path . --resolution 1280x720 res://tests/capture_ui.tscn
extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
	for spec in OS.get_environment("REDMOUNT_UI").split(";", false):
		var f := spec.rsplit(":", true, 1)
		var node: Node = load(f[0]).instantiate()
		add_child(node)
		await get_tree().process_frame
		# "menu_levels" / "menu_settings": ana menünün o sayfasını aç.
		for page in ["levels", "settings", "archive"]:
			if f[1].ends_with(page):
				node._show(node.get("_" + page))
		if f[1].ends_with("tab2"):
			node._select(1)
		if f[1].ends_with("archive"):
			for i in 36:
				Save.secrets[i] = [i % 4, 3]
			node._show(node._archive)
		for i in 90:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(folder.path_join("%s.png" % f[1]))
		node.queue_free()
		await get_tree().process_frame
	get_tree().quit()
