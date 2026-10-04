extends "res://_autoplay.gd"

var _frame := 0


func _process(_delta: float) -> void:
	_frame += 1
	if _frame in [30, 180, 450, 900]:
		await RenderingServer.frame_post_draw
		var folder := OS.get_environment("REDMOUNT_CAPTURE_DIR")
		if not folder.is_empty():
			get_viewport().get_texture().get_image().save_png(
				folder.path_join("play-%04d.png" % _frame))
