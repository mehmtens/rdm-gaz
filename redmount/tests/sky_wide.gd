## Geniş telefonda gökyüzü resmi ekranı kenardan kenara örter: 20:9 (1600) ve 21:9
## (1680 sanal piksel) ekranda iki yanda resimsiz koyu şerit kalmaz; 16:9'da çizim
## eskisiyle birebir (yarı genişlik 760) (tur 202).
##
##  godot --headless --path . res://tests/sky_wide.tscn
extends Node

var _fails := 0


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_fails += 1
		print("FAIL: ", msg)


func _ready() -> void:
	var cam := Camera2D.new()
	add_child(cam)
	cam.make_current()
	var sky: Node2D = DtmLevel._Sky.new()
	# Bölümsüz örnek: yalnız ölçü işlevi sınanır, çizim/ilerleme kapalı.
	add_child(sky)
	sky.visible = false
	sky.process_mode = Node.PROCESS_MODE_DISABLED
	_check(DtmLevel._Sky.half_for(1280.0) == 760.0, "16:9 yarı genişlik 760 değil")
	for w in [1280, 1560, 1600, 1680, 1920]:
		get_tree().root.size = Vector2i(w, 720)
		await get_tree().process_frame
		await get_tree().process_frame
		var view_w: float = sky.get_viewport_rect().size.x
		var half: float = sky.half_width()
		print("ekran %d → görünen %.0f, gökyüzü ±%.0f" % [w, view_w, half])
		# Sarsıntı (±8) ve öne bakış kayması için kenarda en az 24 px pay.
		_check(half >= view_w * 0.5 + 24.0, "%d genişlikte gökyüzü ±%.0f ekranı örtmüyor (görünen %.0f)" % [w, half, view_w])
		cam.zoom = Vector2(1.12, 1.12)
		_check(sky.half_width() <= half, "yakınlaşmada yarı genişlik büyüdü")
		cam.zoom = Vector2.ONE
	print("SKY WIDE: ", "PASS" if _fails == 0 else "FAIL (%d)" % _fails)
	get_tree().quit(0 if _fails == 0 else 1)
