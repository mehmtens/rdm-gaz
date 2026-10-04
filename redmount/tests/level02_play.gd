extends "res://_autoplay.gd"

var _frame := 0


func _ready() -> void:
	Save.purchased = []
	await super._ready()
	assert(_player != null)
	assert(_main.get_node("LevelHolder").get_child_count() > 0)


func _finish_level(msg: String) -> void:
	if not msg.begins_with("CLEARED"):
		push_error("Bölüm 2 tamamlanamadı: " + msg)
		get_tree().quit(1)
		return
	super._finish_level(msg)


func _process(_delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_frame += 1
	if _frame in [30, 180, 450, 900, 1500]:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(
			"res://../outputs/level02/play-%04d.png" % _frame)
