extends "res://_autoplay.gd"

var _capture_frame := 0
var _capture_busy := false

func _ready() -> void:
	Save.purchased = []
	GameState.level_index = 0
	_time_limit = 480.0
	await super._ready()
	assert(_player != null)
	assert(_main.get_node("LevelHolder").get_child_count() > 0)
	var titles: Array[String] = []
	for storefront in preload("res://scripts/systems/level01_dressing.gd").STOREFRONTS.values():
		assert(not titles.has(storefront[0]), "Bölüm 1 mekân adı tekrar ediyor.")
		titles.append(storefront[0])


func _finish_level(msg: String) -> void:
	if not msg.begins_with("CLEARED"):
		push_error("Bölüm 1 tamamlanamadı: " + msg)
		get_tree().quit(1)
		return
	super._finish_level(msg)

func _process(_delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_capture_frame += 1
	if _capture_frame in [30, 180, 450, 900, 1500, 2400, 3300] and not _capture_busy:
		_capture_busy = true
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(
			"res://../outputs/level01/play-%04d.png" % _capture_frame)
		_capture_busy = false
